local M = {}

local function get_workspace()
	return require("workspace")
end

local function get_snacks()
	local ok, snacks = pcall(require, "snacks")
	if not ok then
		vim.notify("Snacks.nvim is not available", vim.log.levels.WARN)
		return nil
	end
	return snacks
end

local function workspace_title(suffix)
	local workspace = get_workspace()
	local name = workspace.workspace_name()
	if name == "" then
		return suffix
	end
	return string.format("%s: %s", name, suffix)
end

local function current_buffer_root(bufnr)
	local workspace = get_workspace()
	return workspace.root_for_buf(bufnr or 0)
end

local function context_root(bufnr)
	local workspace = get_workspace()
	if not workspace.is_open() then
		return nil
	end
	local match = current_buffer_root(bufnr)
	if match then
		return match.root, match.index, true
	end
	local active = workspace.get_active()
	if active then
		return active, nil, false
	end
	return nil
end

local function root_title(root, suffix, from_buffer)
	if not root then
		return suffix
	end
	local prefix = from_buffer and (root.name .. " (buffer root)") or root.name
	return string.format("%s %s", prefix, suffix)
end

local function open_buffer_item(item)
	if not item then
		return
	end
	local workspace = get_workspace()
	if item.root_index then
		workspace.set_active(item.root_index, {
			reason = "workspace_buffer",
			sync_tree = true,
		})
	end
	if item.buf and vim.api.nvim_buf_is_valid(item.buf) then
		vim.api.nvim_set_current_buf(item.buf)
		if item.pos and item.pos[1] and item.pos[1] > 0 then
			pcall(vim.api.nvim_win_set_cursor, 0, item.pos)
		end
	end
end

local function list_workspace_buffers()
	local workspace = get_workspace()
	local items = {}
	local current_buf = vim.api.nvim_get_current_buf()
	local alternate_buf = vim.fn.bufnr("#")
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].buflisted and vim.bo[buf].buftype ~= "nofile" then
			local name = vim.api.nvim_buf_get_name(buf)
			local match = name ~= "" and workspace.root_for_path(name) or nil
			if match then
				local info = vim.fn.getbufinfo(buf)[1]
				local mark = vim.api.nvim_buf_get_mark(buf, '"')
				local flags = {}
				if buf == current_buf then
					flags[#flags + 1] = "%"
				elseif buf == alternate_buf then
					flags[#flags + 1] = "#"
				end
				if info.hidden == 1 then
					flags[#flags + 1] = "h"
				elseif #(info.windows or {}) > 0 then
					flags[#flags + 1] = "a"
				end
				if vim.bo[buf].readonly then
					flags[#flags + 1] = "="
				end
				if info.changed == 1 then
					flags[#flags + 1] = "+"
				end
				items[#items + 1] = {
					buf = buf,
					file = name,
					root_index = match.index,
					root_name = match.root.name,
					flags = table.concat(flags),
					info = info,
					pos = mark[1] ~= 0 and mark or { info.lnum, 0 },
				}
			end
		end
	end
	table.sort(items, function(a, b)
		return a.info.lastused > b.info.lastused
	end)
	return items
end

function M.pick_root()
	local workspace = get_workspace()
	local roots = workspace.get_roots()
	if #roots == 0 then
		vim.notify("No workspace roots are loaded", vim.log.levels.WARN)
		return
	end

	local active = workspace.get_active()
	local items = {}
	for index, root in ipairs(roots) do
		items[#items + 1] = {
			index = index,
			name = root.name,
			path = root.path,
			active = active and active.path == root.path or false,
		}
	end

	vim.ui.select(items, {
		prompt = "Select workspace root",
		format_item = function(item)
			local marker = item.active and "*" or " "
			return string.format("%s %s — %s", marker, item.name, item.path)
		end,
	}, function(choice)
		if choice then
			workspace.set_active(choice.index)
		end
	end)
end

function M.workspace_files()
	local workspace = get_workspace()
	local snacks = get_snacks()
	if not snacks then
		return
	end
	local dirs = workspace.project_dirs()
	if #dirs == 0 then
		vim.notify("No workspace roots are loaded", vim.log.levels.WARN)
		return
	end
	snacks.picker.files({
		dirs = dirs,
		title = workspace_title("Workspace Files"),
	})
end

function M.workspace_grep()
	local workspace = get_workspace()
	local snacks = get_snacks()
	if not snacks then
		return
	end
	local dirs = workspace.project_dirs()
	if #dirs == 0 then
		vim.notify("No workspace roots are loaded", vim.log.levels.WARN)
		return
	end
	snacks.picker.grep({
		dirs = dirs,
		title = workspace_title("Workspace Grep"),
	})
end

function M.workspace_buffers()
	local workspace = get_workspace()
	local snacks = get_snacks()
	if not snacks then
		return
	end
	if not workspace.is_open() then
		snacks.picker.buffers()
		return
	end
	local items = list_workspace_buffers()
	if #items == 0 then
		vim.notify("No workspace buffers are open", vim.log.levels.WARN)
		return
	end
	for _, item in ipairs(items) do
		local flags = item.flags ~= "" and (" [" .. item.flags .. "]") or ""
		item.text = string.format("[%s]%s %s", item.root_name, flags, item.file)
		item.idx = item.info.lastused
	end
	snacks.picker.pick({
		source = "workspace_buffers",
		title = workspace_title("Workspace Buffers"),
		items = items,
		format = "text",
		preview = "file",
		confirm = function(picker, item)
			picker:close()
			vim.schedule(function()
				open_buffer_item(item)
			end)
		end,
	})
end

function M.active_root_files()
	local workspace = get_workspace()
	local snacks = get_snacks()
	if not snacks then
		return
	end
	local active = workspace.get_active()
	if not active then
		vim.notify("No active workspace root", vim.log.levels.WARN)
		return
	end
	snacks.picker.files({
		cwd = active.path,
		title = string.format("%s Files", active.name),
	})
end

function M.active_root_grep()
	local workspace = get_workspace()
	local snacks = get_snacks()
	if not snacks then
		return
	end
	local active = workspace.get_active()
	if not active then
		vim.notify("No active workspace root", vim.log.levels.WARN)
		return
	end
	snacks.picker.grep({
		cwd = active.path,
		title = string.format("%s Grep", active.name),
	})
end

function M.context_files()
	local snacks = get_snacks()
	if not snacks then
		return
	end
	local root, _, from_buffer = context_root()
	if not root then
		snacks.picker.files()
		return
	end
	snacks.picker.files({
		cwd = root.path,
		title = root_title(root, "Files", from_buffer),
	})
end

function M.context_smart_files()
	local snacks = get_snacks()
	if not snacks then
		return
	end
	local root, _, from_buffer = context_root()
	if not root then
		snacks.picker.smart()
		return
	end
	snacks.picker.smart({
		cwd = root.path,
		title = root_title(root, "Smart Files", from_buffer),
	})
end

function M.context_grep()
	local snacks = get_snacks()
	if not snacks then
		return
	end
	local root, _, from_buffer = context_root()
	if not root then
		snacks.picker.grep()
		return
	end
	snacks.picker.grep({
		cwd = root.path,
		title = root_title(root, "Grep", from_buffer),
	})
end

function M.context_grep_word()
	local snacks = get_snacks()
	if not snacks then
		return
	end
	local root, _, from_buffer = context_root()
	if not root then
		snacks.picker.grep_word()
		return
	end
	snacks.picker.grep_word({
		cwd = root.path,
		title = root_title(root, "Word Grep", from_buffer),
	})
end

function M.sync_tree(path)
	local tree_open = false
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].filetype == "neo-tree" then
			tree_open = true
			break
		end
	end

	if not tree_open then
		return
	end

	local ok, err = pcall(vim.cmd, "Neotree source=filesystem position=left dir=" .. vim.fn.fnameescape(path))
	if not ok then
		vim.notify("Failed to sync Neo-tree root: " .. err, vim.log.levels.WARN)
	end
	pcall(function()
		require("lualine").refresh()
	end)
end

return M
