local events = require("neo-tree.events")
local common_commands = require("neo-tree.sources.common.commands")
local file_items = require("neo-tree.sources.common.file-items")
local git = require("neo-tree.git")
local manager = require("neo-tree.sources.manager")
local renderer = require("neo-tree.ui.renderer")
local utils = require("neo-tree.utils")

local uv = vim.uv or vim.loop
local commands = require("neo-tree.sources.git_status.commands")

local M = {
	name = "git_status",
	display_name = " 󰊢 Git ",
	components = require("neo-tree.sources.git_status.components"),
	commands = commands,
}

local watchers = {}
local worktree_watchers = {}
local refresh_tokens = {}
local status_cache_by_root = {}
local full_untracked_roots = {}
local full_untracked_tokens = {}
local config = {}

local function normalize_path(path)
	return utils.normalize_path(path or vim.fn.getcwd(-1, -1))
end

local function normalize_root_path(path)
	path = normalize_path(path)
	return uv.fs_realpath(path) or path
end

local function is_renderable_status(status)
	-- Neo-tree bubbles some statuses up to parent directories as tables. The git
	-- status view should list concrete changed paths and let file-items create the
	-- parent folder hierarchy on demand.
	return status ~= nil and type(status) ~= "table" and status ~= "!"
end

local function status_under_root(root, path)
	return utils.is_subpath(root, path) or utils.is_subpath(path, root)
end

local function force_full_untracked_status(args)
	local git_root = args.git_root and normalize_root_path(args.git_root)
	if not git_root or not full_untracked_roots[git_root] then
		return
	end

	-- Built-in git_status uses `--untracked-files=all` so untracked directories
	-- are expanded into individual files. Neo-tree's async path defaults to
	-- `normal`, which can render only the parent directory and disagree with
	-- lazygit. Keep the async first pass (`no`) intact and only upgrade full scans
	-- while a git_status tree for this worktree is actually visible.
	for index, value in ipairs(args.status_args or {}) do
		if value == "--untracked-files=normal" then
			args.status_args[index] = "--untracked-files=all"
			return
		end
	end
end

local function create_root(state, root_path)
	local context = file_items.create_context()
	context.state = state

	local root = file_items.create_item(context, root_path, "directory")
	root.name = vim.fn.fnamemodify(root.path, ":~")
	root.loaded = true
	root.search_pattern = state.search_pattern
	context.folders[root.path] = root

	return context, root
end

local function render_status(state, status_lookup, root_path)
	root_path = normalize_path(root_path or state.path)
	local context, root = create_root(state, root_path)

	if status_lookup then
		for path, status in pairs(status_lookup) do
			path = normalize_path(path)
			if is_renderable_status(status) and status_under_root(root_path, path) then
				local ok, item = pcall(file_items.create_item, context, path)
				if ok then
					if item.type == "unknown" then
						item.type = "file"
					end
					item.extra = vim.tbl_extend("force", item.extra or {}, { git_status = status })
				end
			end
		end
	end

	state.default_expanded_nodes = {}
	for id, _ in pairs(context.folders) do
		table.insert(state.default_expanded_nodes, id)
	end
	file_items.advanced_sort(root.children, state)
	renderer.show_nodes({ root }, state)
end

local function cache_key(path)
	return normalize_root_path(path)
end

local function merge_statuses(primary, secondary)
	if not secondary then
		return primary
	end

	local merged = vim.tbl_extend("force", primary or {}, secondary)
	return merged
end

local function render_cached_status(state)
	-- find_existing_worktree only looks for a worktree *above* the path, so a
	-- view opened at the worktree root itself would find nothing and render an
	-- empty tree over the real status.
	local worktree_root, worktree = state.path, git.worktrees[state.path]
	if not worktree then
		worktree_root, worktree = git.find_existing_worktree(state.path)
	end
	local cached = worktree_root and status_cache_by_root[cache_key(worktree_root)]
	if cached then
		render_status(state, cached, state.path or worktree_root)
		return true
	end

	if worktree and worktree.status then
		render_status(state, worktree.status, state.path or worktree_root)
		return true
	end

	render_status(state, nil, state.path)
	return false
end

local function request_async_status(state)
	local path = state.path
	refresh_tokens[state.id] = (refresh_tokens[state.id] or 0) + 1
	local token = refresh_tokens[state.id]

	git.find_worktree_info(path, function(worktree_root)
		-- Request full-worktree async status and filter locally while rendering.
		-- Neo-tree's async git cache is keyed only by worktree root, so scoped
		-- requests cannot be safely attributed to individual source states.
		local root_key = worktree_root and cache_key(worktree_root)
		if root_key then
			full_untracked_roots[root_key] = true
			full_untracked_tokens[root_key] = (full_untracked_tokens[root_key] or 0) + 1
			local token = full_untracked_tokens[root_key]
			vim.defer_fn(function()
				if full_untracked_tokens[root_key] == token then
					full_untracked_roots[root_key] = nil
					full_untracked_tokens[root_key] = nil
				end
			end, config.full_untracked_window_ms or 10000)
		end
		git.status_async(worktree_root or path, state.git_base_by_worktree, config.git_status_async_options or {})
	end)

	-- If async status produces no event because cached raw git output is unchanged,
	-- render from cache shortly after the request so explicit refresh still updates
	-- newly opened Neo-tree windows without blocking the UI.
	vim.defer_fn(function()
		if refresh_tokens[state.id] ~= token or not renderer.window_exists(state) then
			return
		end
		render_cached_status(state)
	end, config.async_cache_render_delay or 250)
end

local function schedule_visible_refresh(worktree_root)
	utils.debounce("async_neotree_git_status:" .. worktree_root, function()
		manager._for_each_state(M.name, function(state)
			if state.path and renderer.window_exists(state) and status_under_root(worktree_root, state.path) then
				request_async_status(state)
			end
		end)
	end, config.watch_debounce or 1000, utils.debounce_strategy.CALL_LAST_ONLY)
end

local function start_fs_event(handle, path, opts, callback)
	local ok, result = pcall(handle.start, handle, path, opts, callback)
	return ok and result ~= nil
end

local function watch_git_dir(worktree_root, git_dir)
	if not worktree_root or not git_dir or watchers[worktree_root] then
		return
	end

	local handle = uv.new_fs_event()
	if not handle then
		return
	end

	local started = start_fs_event(handle, git_dir, { watch_entry = false, stat = false, recursive = false }, function(err, fname)
		if err or not fname or vim.endswith(fname, ".lock") or fname:find("_null%-ls_") then
			return
		end

		vim.schedule(function()
			schedule_visible_refresh(worktree_root)
		end)
	end)

	if started then
		watchers[worktree_root] = handle
	else
		handle:close()
	end
end

local function watch_worktree(worktree_root)
	if not worktree_root or worktree_watchers[worktree_root] then
		return
	end

	local handle = uv.new_fs_event()
	if not handle then
		return
	end

	local callback = function(err, fname)
		if err then
			return
		end

		-- Git metadata changes are handled by the dedicated git-dir watcher. Filtering
		-- them here avoids duplicate refresh storms while lazygit or Git updates `.git`.
		if fname == ".git" or (fname and fname:find("^%.git[/\\]")) then
			return
		end

		vim.schedule(function()
			schedule_visible_refresh(worktree_root)
		end)
	end

	local started = start_fs_event(handle, worktree_root, { watch_entry = false, stat = false, recursive = true }, callback)
		or start_fs_event(handle, worktree_root, { watch_entry = false, stat = false, recursive = false }, callback)

	if started then
		worktree_watchers[worktree_root] = handle
	else
		handle:close()
	end
end

local function ensure_git_watcher(path)
	git.find_worktree_info(path, function(worktree_root, git_dir)
		watch_git_dir(worktree_root, git_dir)
		watch_worktree(worktree_root)
	end)
end

local function root_matches_state(state, git_root)
	return state.path and git_root and status_under_root(git_root, state.path)
end

local function refresh_visible_states_for_path(path)
	manager._for_each_state(M.name, function(state)
		if state.path and renderer.window_exists(state) and (not path or status_under_root(state.path, path)) then
			request_async_status(state)
		elseif not renderer.window_exists(state) then
			state.dirty = true
		end
	end)
end

commands.move = function(state)
	local function navigate(_, destination)
		vim.schedule(function()
			manager.navigate(state, state.path, destination)
		end)
	end

	common_commands.move(state, navigate)
end

function M.navigate(state, path, path_to_reveal, callback)
	state.path = normalize_root_path(utils.truthy(path) and path or state.path)
	state.dirty = false

	if path_to_reveal then
		renderer.position.set(state, path_to_reveal)
	end

	render_cached_status(state)
	ensure_git_watcher(state.path)
	request_async_status(state)

	if type(callback) == "function" then
		vim.schedule(callback)
	end
end

function M.setup(source_config, global_config)
	config = vim.tbl_deep_extend("force", {
		async_cache_render_delay = 250,
		watch_debounce = 1000,
		git_status_async_options = global_config.git_status_async_options or {},
	}, source_config.async_git_status or {})

	manager.subscribe(M.name, {
		event = events.BEFORE_GIT_STATUS,
		handler = force_full_untracked_status,
	})

	manager.subscribe(M.name, {
		event = events.GIT_STATUS_CHANGED,
		handler = function(args)
			local git_root = args.git_root and cache_key(args.git_root)
			if git_root and args.git_status then
				status_cache_by_root[git_root] = merge_statuses(args.git_status, args.git_status_diff_base)
			end

			manager._for_each_state(M.name, function(state)
				if renderer.window_exists(state) and root_matches_state(state, args.git_root) then
					render_status(state, status_cache_by_root[git_root] or args.git_status, state.path or args.git_root)
				end
			end)
		end,
	})

	manager.subscribe(M.name, {
		event = events.GIT_EVENT,
		handler = function()
			refresh_visible_states_for_path()
		end,
	})

	if global_config.enable_refresh_on_write then
		manager.subscribe(M.name, {
			event = events.VIM_BUFFER_CHANGED,
			handler = function(args)
				if utils.is_real_file(args.afile) then
					refresh_visible_states_for_path(args.afile)
				end
			end,
		})
	end

	if source_config.bind_to_cwd then
		manager.subscribe(M.name, {
			event = events.VIM_DIR_CHANGED,
			handler = function()
				refresh_visible_states_for_path()
			end,
		})
	end

	if global_config.enable_diagnostics then
		manager.subscribe(M.name, {
			event = events.STATE_CREATED,
			handler = function(state)
				state.diagnostics_lookup = utils.get_diagnostic_counts()
			end,
		})
		manager.subscribe(M.name, {
			event = events.VIM_DIAGNOSTIC_CHANGED,
			handler = function(args)
				manager.diagnostics_changed(M.name, args)
			end,
		})
	end

	if global_config.enable_modified_markers then
		manager.subscribe(M.name, {
			event = events.VIM_BUFFER_MODIFIED_SET,
			handler = function(args)
				manager.opened_buffers_changed(M.name, args)
			end,
		})
	end

	manager.subscribe(M.name, {
		event = events.VIM_LEAVE,
		handler = function()
			for root, handle in pairs(watchers) do
				handle:stop()
				handle:close()
				watchers[root] = nil
			end
			for root, handle in pairs(worktree_watchers) do
				handle:stop()
				handle:close()
				worktree_watchers[root] = nil
			end
		end,
	})
end

return M
