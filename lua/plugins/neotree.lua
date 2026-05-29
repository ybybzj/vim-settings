local cmd = vim.cmd

local open_grug_far = require("config.finder").find_and_replace

local CURATED_CONFIG_FILENAMES = {
	".neotree-curated",
	".nvim/neotree-curated",
}

local curated_renderer_patched = false
local curated_config_watchers = {}

local function get_curated_project_root(config_path)
	local utils = require("neo-tree.utils")
	local config_dir = utils.normalize_path(vim.fs.dirname(config_path))
	if vim.fs.basename(config_dir) == ".nvim" then
		return utils.normalize_path(vim.fs.dirname(config_dir))
	end
	return config_dir
end

local function refresh_curated_states(config_path)
	local manager = require("neo-tree.sources.manager")
	local should_refresh = false
	manager._for_each_state("filesystem", function(state)
		local cached = state.curated_spec
		if cached and cached.config_path == config_path then
			state.curated_spec = nil
			should_refresh = true
		end
	end)
	if should_refresh then
		manager.refresh("filesystem")
	end
end

local function ensure_curated_config_watcher(config_path)
	if curated_config_watchers[config_path] then
		return
	end

	local watcher = vim.uv.new_fs_event()
	if not watcher then
		return
	end

	-- Curated view depends on a project-local line-based config that may be edited outside the
	-- current buffer, so watch the chosen config file and invalidate cached specs.
	local ok, err = watcher:start(config_path, {}, function(watch_err)
		if watch_err then
			vim.schedule(function()
				vim.notify(
					("Neo-tree curated watcher error: %s (%s)"):format(watch_err, config_path),
					vim.log.levels.WARN
				)
			end)
			return
		end
		vim.schedule(function()
			refresh_curated_states(config_path)
		end)
	end)
	if not ok then
		watcher:close()
		vim.notify(
			("Neo-tree curated watcher failed: %s (%s)"):format(err or "unknown error", config_path),
			vim.log.levels.WARN
		)
		return
	end

	curated_config_watchers[config_path] = watcher
end

local function refresh_on_next_open(source)
	local ok, manager = pcall(require, "neo-tree.sources.manager")
	if not ok then
		return
	end

	manager.get_state(source).dirty = true
end

local function toggle_filesystem_view()
	local command = require("neo-tree.command")

	-- Keep Neo-tree as one sidebar: switching back to files should replace the
	-- git-status source instead of leaving a second Neo-tree window around.
	command.execute({ action = "close", source = "git_status", position = "left" })
	refresh_on_next_open("filesystem")
	command.execute({ action = "focus", source = "filesystem", position = "left", toggle = true, reveal = true })
end

local function toggle_git_status_view()
	local command = require("neo-tree.command")

	-- Use Neo-tree's git_status source as the compact "what changed?" view.
	-- Closing filesystem first makes this replace the normal file list in-place.
	command.execute({ action = "close", source = "filesystem", position = "left" })
	refresh_on_next_open("git_status")
	command.execute({ action = "focus", source = "git_status", position = "left", toggle = true })
end

local function reveal_filesystem_view()
	local command = require("neo-tree.command")

	command.execute({ action = "close", source = "git_status", position = "left" })
	command.execute({ action = "focus", source = "filesystem", position = "left", reveal = true })
end

local function get_curated_config_path(start_path)
	local utils = require("neo-tree.utils")
	local path = start_path or vim.fn.getcwd()
	local stat = vim.uv.fs_stat(path)
	if stat and stat.type == "file" then
		path = vim.fs.dirname(path)
	end
	local matches = vim.fs.find(CURATED_CONFIG_FILENAMES, {
		path = path,
		upward = true,
		type = "file",
	})
	if not matches or not matches[1] then
		return nil
	end
	return utils.normalize_path(matches[1])
end

local function parse_curated_config(config_path)
	local utils = require("neo-tree.utils")
	local stat = vim.uv.fs_stat(config_path)
	if not stat then
		return nil, "config file is missing"
	end

	local lines = vim.fn.readfile(config_path)
	local root_path = get_curated_project_root(config_path)
	local entries = {}
	local seen_paths = {}
	local warnings = {}
	for index, raw_line in ipairs(lines) do
		local line = vim.trim(raw_line)
		if line ~= "" and not vim.startswith(line, "#") then
			local absolute_path
			if utils.abspath_prefix(line) then
				absolute_path = utils.normalize_path(line)
			else
				absolute_path = utils.normalize_path(utils.path_join(root_path, line))
			end

			if absolute_path ~= root_path and not utils.is_subpath(root_path, absolute_path) then
				return nil, ("line %d must stay inside the project root: %s"):format(index, line)
			end

			local entry_stat = vim.uv.fs_stat(absolute_path)
			if not entry_stat or (entry_stat.type ~= "directory" and entry_stat.type ~= "file") then
				warnings[#warnings + 1] = ("Skipping missing path: %s"):format(line)
			elseif not seen_paths[absolute_path] then
				seen_paths[absolute_path] = true
				entries[#entries + 1] = {
					path = absolute_path,
					kind = entry_stat.type,
				}
			end
		end
	end

	if vim.tbl_isempty(entries) then
		return nil, "config file has no valid existing file or directory entries"
	end

	return {
		config_path = config_path,
		root_path = root_path,
		entries = entries,
		mtime = stat.mtime,
		warnings = warnings,
	}
end

local function get_curated_spec(state)
	local config_path = get_curated_config_path(state.path)
	if not config_path then
		state.curated_spec = nil
		return nil
	end

	local stat = vim.uv.fs_stat(config_path)
	if not stat then
		state.curated_spec = nil
		return nil
	end

	local cached = state.curated_spec
	if cached and cached.config_path == config_path then
		local cached_mtime = cached.mtime or {}
		local stat_mtime = stat.mtime or {}
		if cached_mtime.sec == stat_mtime.sec and cached_mtime.nsec == stat_mtime.nsec then
			return cached
		end
	end

	local spec, err = parse_curated_config(config_path)
	if not spec then
		vim.notify(
			("Neo-tree curated view: %s (%s)"):format(err, config_path),
			vim.log.levels.WARN
		)
		state.curated_spec = nil
		return nil
	end

	ensure_curated_config_watcher(config_path)
	for _, warning in ipairs(spec.warnings or {}) do
		vim.notify(("Neo-tree curated view: %s"):format(warning), vim.log.levels.WARN)
	end
	state.curated_spec = spec
	return spec
end

local function item_matches_curated_entry(item_path, entry)
	local utils = require("neo-tree.utils")
	if item_path == entry.path then
		return true
	end
	if utils.is_subpath(item_path, entry.path) then
		return true
	end
	if entry.kind == "directory" and utils.is_subpath(entry.path, item_path) then
		return true
	end
	return false
end

local function should_keep_curated_item(item, spec)
	for _, entry in ipairs(spec.entries) do
		if item_matches_curated_entry(item.path, entry) then
			return true
		end
	end
	return false
end

local function prune_curated_items(items, spec)
	local pruned = {}
	for _, item in ipairs(items or {}) do
		local children = nil
		if item.children then
			children = prune_curated_items(item.children, spec)
		end

		if should_keep_curated_item(item, spec) or (children and #children > 0) then
			local copy = vim.deepcopy(item)
			if copy.children then
				copy.children = children or {}
			end
			-- Show an in-tree mode badge without creating a separate Neo-tree source.
			if copy.path == spec.root_path then
				copy.name = copy.name .. " [curated]"
			end
			pruned[#pruned + 1] = copy
		end
	end
	return pruned
end

local function setup_curated_renderer_patch()
	if curated_renderer_patched then
		return
	end
	curated_renderer_patched = true

	local renderer = require("neo-tree.ui.renderer")
	local original_show_nodes = renderer.show_nodes

	renderer.show_nodes = function(source_items, state, parent_id, callback)
		if state and state.name == "filesystem" and state.curated_mode then
			local spec = get_curated_spec(state)
			if spec and #spec.entries > 0 then
				source_items = prune_curated_items(source_items, spec)
			else
				state.curated_mode = false
			end
		end
		return original_show_nodes(source_items, state, parent_id, callback)
	end
end

local function toggle_curated_filesystem_view(state)
	local manager = require("neo-tree.sources.manager")
	local command = require("neo-tree.command")

	if not state or state.name ~= "filesystem" then
		command.execute({ action = "focus", source = "filesystem", position = "left" })
		state = manager.get_state("filesystem")
	end

	local spec = get_curated_spec(state)
	if not spec or vim.tbl_isempty(spec.entries) then
		vim.notify(
			("Neo-tree curated view: no config found (looked for %s)"):format(table.concat(CURATED_CONFIG_FILENAMES, ", ")),
			vim.log.levels.INFO
		)
		return
	end

	state.curated_mode = not state.curated_mode
	manager.refresh("filesystem")
	command.execute({ action = "focus", source = "filesystem", position = "left" })
	vim.notify(
		("Neo-tree curated view: %s"):format(state.curated_mode and "on" or "off"),
		vim.log.levels.INFO
	)
end

local function config()
	local neoTree = require("neo-tree")

	setup_curated_renderer_patch()

	cmd("let g:neo_tree_remove_legacy_commands = 1")
	-- handle rename when file is modified
	local function on_move(data)
		Snacks.rename.on_rename_file(data.source, data.destination)
	end

	local events = require("neo-tree.events")

	vim.api.nvim_create_autocmd("BufWritePost", {
		group = vim.api.nvim_create_augroup("NeoTreeCuratedConfig", { clear = true }),
		pattern = CURATED_CONFIG_FILENAMES,
		callback = function(args)
			local utils = require("neo-tree.utils")
			refresh_curated_states(utils.normalize_path(args.file))
		end,
	})

	neoTree.setup({
		sources = {
			"filesystem",
			"buffers",
			"config.neotree_async_git_status",
		},
		enable_diagnostics = true,
		git_status_scope_to_path = true,
		open_files_do_not_replace_types = { "terminal", "trouble", "qf", "Spectre", "ctrlsf" },
		auto_clean_after_session_restore = true,
		default_component_configs = {
			icon = {
				folder_empty = "󰜌",
			},
			git_status = {
				symbols = {
					-- Change type
					added = "✚", -- or "✚", but this is redundant info if you use git_status_colors on the name
					modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
					deleted = "✖", -- this can only be used in the git_status source
					renamed = "󰁕", -- this can only be used in the git_status source
					-- Status type
					untracked = "",
					ignored = "",
					unstaged = "󰄱",
					staged = "",
					conflict = "",
				},
			},
		},
		filesystem = {
			follow_current_file = { enable = true },
			hijack_netrw_behavior = "open_current",
			-- Keep Neo-tree from refreshing on every external .git/filesystem change.
			-- This makes git_status usable in large repos; press `R` to refresh manually.
			use_libuv_file_watcher = false,
			window = {
				mappings = {
					["u"] = "navigate_up",
					["H"] = "toggle_hidden",
					["J"] = "toggle_curated_view",
					["/"] = "fuzzy_finder",
					["D"] = "fuzzy_finder_directory",
					--["/"] = "filter_as_you_type", -- this was the default until v1.28
					-- ["#"] = "fuzzy_sorter", -- fuzzy sorting using the fzy algorithm
					-- ["D"] = "fuzzy_sorter_directory",
					["f"] = "filter_on_submit",
					["<C-x>"] = "clear_filter",
					["<bs>"] = "navigate_up",
					["."] = "set_root",
					["[g"] = "prev_git_modified",
					["]g"] = "next_git_modified",
				},
			},
			filtered_items = {
				visible = false, -- when true, they will just be displayed differently than normal items
				force_visible_in_empty_folder = false, -- when true, hidden files will be shown if the root folder is otherwise empty
				show_hidden_count = true, -- when true, the number of hidden items in each folder will be shown as the last entry
				hide_dotfiles = false,
				hide_gitignored = false,
				hide_hidden = true, -- only works on Windows for hidden files/directories
				hide_by_name = {
					".DS_Store",
					"thumbs.db",
					".git",
					--"node_modules",
				},
				hide_by_pattern = { -- uses glob style patterns
					--"*.meta",
					--"*/src/*/tsconfig.json"
				},
				always_show = { -- remains visible even if other settings would normally hide it
					--".gitignored",
				},
				never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
					--".DS_Store",
					--"thumbs.db"
				},
				never_show_by_pattern = { -- uses glob style patterns
					--".null-ls_*",
				},
			},
		},
		use_default_mappings = false,
		window = {
			mappings = {
				["<2-LeftMouse>"] = "open",
				["<cr>"] = "open",
				["<right>"] = "open",
				["<esc>"] = "revert_preview",
				["P"] = { "toggle_preview", config = { use_float = true } },
				["l"] = "focus_preview",
				["S"] = "open_split",
				-- ["S"] = "split_with_window_picker",
				["s"] = "open_vsplit",
				-- ["s"] = "vsplit_with_window_picker",
				["t"] = "open_tabnew",
				-- ["<cr>"] = "open_drop",
				-- ["t"] = "open_tab_drop",
				["w"] = "open_with_window_picker",
				["C"] = "close_node",
				["<left>"] = "close_node",
				["z"] = "close_all_nodes",
				--["Z"] = "expand_all_nodes",
				["R"] = "refresh",
				["a"] = {
					"add",
					-- some commands may take optional config options, see `:h neo-tree-mappings` for details
					config = {
						show_path = "relative", -- "none", "relative", "absolute"
					},
				},
				["A"] = "add_directory", -- also accepts the config.show_path and config.insert_as options.
				["d"] = "delete",
				["r"] = "rename",
				["y"] = "copy_to_clipboard",
				["x"] = "cut_to_clipboard",
				["p"] = "paste_from_clipboard",
				["c"] = "copy", -- takes text input for destination, also accepts the config.show_path and config.insert_as options
				["m"] = "move", -- takes text input for destination, also accepts the config.show_path and config.insert_as options
				["e"] = "toggle_auto_expand_width",
				["q"] = "close_window",
				["?"] = "show_help",
				["<"] = "prev_source",
				[">"] = "next_source",
				["Y"] = "copy_selector",
				["F"] = "grug_far_replace",
			},
		},
		commands = {
			-- for copy paths
			copy_selector = function(state)
				local node = state.tree:get_node()
				local filepath = node:get_id()
				local filename = node.name
				local modify = vim.fn.fnamemodify

				local vals = {
					["1.RelPATH"] = modify(filepath, ":."),
					-- ["BASENAME"] = modify(filename, ":r"),
					-- ["EXTENSION"] = modify(filename, ":e"),
					["3.FILENAME"] = filename,
					-- ["PATH (HOME)"] = modify(filepath, ":~"),
					["2.AbsPATH"] = filepath,
					-- ["URI"] = vim.uri_from_fname(filepath),
				}

				local options = vim.tbl_filter(function(val)
					return vals[val] ~= ""
				end, vim.tbl_keys(vals))
				if vim.tbl_isempty(options) then
					vim.notify("No values to copy", vim.log.levels.WARN)
					return
				end
				table.sort(options)
				vim.ui.select(options, {
					prompt = "Choose to copy to clipboard:",
					format_item = function(item)
						return ("%s: %s"):format(item, vals[item])
					end,
				}, function(choice)
					local result = vals[choice]
					if result then
						vim.notify(("Copied: `%s`"):format(result))
						vim.fn.setreg("+", result)
					end
				end)
			end,

			grug_far_replace = function(state)
				local node = state.tree:get_node()
				local opts = {
					instanceName = "far",
					-- also escape the paths if space is there
					-- if you want files to be selected, use ':p' only, see filename-modifiers
					paths = node.type == "directory" and vim.fn.fnameescape(vim.fn.fnamemodify(node:get_id(), ":p"))
						or vim.fn.fnameescape(vim.fn.fnamemodify(node:get_id(), ":h")),
				}
				open_grug_far(opts)
			end,

			toggle_curated_view = function(state)
				toggle_curated_filesystem_view(state)
			end,
		},
		event_handlers = {
			{ event = events.FILE_MOVED, handler = on_move },
			{ event = events.FILE_RENAMED, handler = on_move },
		},
	})

	-- keymap("", "<leader>l", "<cmd>Neotree toggle reveal=true<cr>")
	-- keymap("", "<leader>gf", "<cmd>Neotree reveal=true<cr>")
end

return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	lazy = false,
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		"stevearc/dressing.nvim",
		"MagicDuck/grug-far.nvim",
	},
	config = config,
	keys = {
		{ "<leader>l", toggle_filesystem_view, desc = "Toggle Neotree" },
		{ "<leader>k", toggle_git_status_view, desc = "Toggle Git Status Tree" },
		{ "<leader>gf", reveal_filesystem_view, desc = "Reveal In Noetree" },
		{ "<leader>j", toggle_curated_filesystem_view, desc = "Toggle Neotree Curated View" },
	},
}
