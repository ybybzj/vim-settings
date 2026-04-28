local uv = vim.uv or vim.loop

local M = {}

local state = {
	workspace_file = nil,
	name = nil,
	roots = {},
	active_index = nil,
}

local setup_done = false

local function joinpath(...)
	if vim.fs and vim.fs.joinpath then
		return vim.fs.joinpath(...)
	end
	return table.concat({ ... }, "/")
end

local function is_abs(path)
	if vim.fs and vim.fs.isabs then
		return vim.fs.isabs(path)
	end
	return path:match("^/") ~= nil or path:match("^%a:[/\\]") ~= nil
end

local function normalize_fs_path(path)
	if vim.fs and vim.fs.normalize then
		return vim.fs.normalize(path)
	end
	return vim.fn.fnamemodify(path, ":p")
end

local function dirname(path)
	if vim.fs and vim.fs.dirname then
		return vim.fs.dirname(path)
	end
	return vim.fn.fnamemodify(path, ":h")
end

local function normalize_path(path, base)
	if not path or path == "" then
		return nil
	end
	local resolved = path
	if base and not is_abs(resolved) then
		resolved = joinpath(base, resolved)
	end
	resolved = vim.fn.fnamemodify(resolved, ":p")
	resolved = normalize_fs_path(resolved)
	local real = uv.fs_realpath(resolved)
	if real then
		resolved = normalize_fs_path(real)
	end
	resolved = resolved:gsub("/+$", "")
	return resolved
end

local function is_dir(path)
	local stat = uv.fs_stat(path)
	return stat and stat.type == "directory"
end

local function basename(path)
	if vim.fs and vim.fs.basename then
		return vim.fs.basename(path)
	end
	return vim.fn.fnamemodify(path, ":t")
end

local function workspace_basename(path)
	local name = basename(path)
	return (name:gsub("%.code%-workspace$", ""))
end

local function active_root()
	if not state.active_index then
		return nil
	end
	return state.roots[state.active_index]
end

local function emit(pattern, data)
	vim.api.nvim_exec_autocmds("User", {
		pattern = pattern,
		data = data,
	})
end

local function parse_workspace_file(workspace_file)
	local path = normalize_path(workspace_file)
	if not path or vim.fn.filereadable(path) ~= 1 then
		error("Workspace file not found: " .. tostring(workspace_file))
	end

	local decoded = vim.json.decode(table.concat(vim.fn.readfile(path), "\n"))
	if type(decoded) ~= "table" or type(decoded.folders) ~= "table" then
		error("Invalid .code-workspace file: missing folders array")
	end

	local workspace_dir = dirname(path)
	local roots = {}
	for _, folder in ipairs(decoded.folders) do
		local folder_path
		local folder_name
		if type(folder) == "string" then
			folder_path = folder
		elseif type(folder) == "table" then
			folder_path = folder.path
			folder_name = folder.name
		end

		local abs_path = normalize_path(folder_path, workspace_dir)
		if abs_path and is_dir(abs_path) then
			roots[#roots + 1] = {
				name = folder_name or basename(abs_path),
				path = abs_path,
			}
		end
	end

	if #roots == 0 then
		error("No existing directories found in workspace file")
	end

	return {
		workspace_file = path,
		name = workspace_basename(path),
		roots = roots,
	}
end

local function find_root(target)
	if type(target) == "number" then
		return state.roots[target] and target or nil
	end

	if type(target) ~= "string" then
		return nil
	end

	local normalized = normalize_path(target)
	for index, root in ipairs(state.roots) do
		if root.path == normalized or root.name == target then
			return index
		end
	end

	return nil
end

function M.is_open()
	return state.workspace_file ~= nil and #state.roots > 0
end

function M.get()
	return vim.deepcopy(state)
end

function M.get_roots()
	return vim.deepcopy(state.roots)
end

function M.get_active()
	local root = active_root()
	return root and vim.deepcopy(root) or nil
end

function M.project_dirs()
	local dirs = {}
	for _, root in ipairs(state.roots) do
		dirs[#dirs + 1] = root.path
	end
	return dirs
end

function M.active_dir()
	local root = active_root()
	return root and root.path or vim.fn.getcwd(-1, -1)
end

function M.workspace_name()
	return state.name or ""
end

function M.root_for_path(path)
	local normalized = normalize_path(path)
	if not normalized then
		return nil
	end
	for index, root in ipairs(state.roots) do
		local prefix = root.path .. "/"
		if normalized == root.path or normalized:sub(1, #prefix) == prefix then
			return {
				index = index,
				root = vim.deepcopy(root),
			}
		end
	end
	return nil
end

function M.root_for_buf(bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return nil
	end
	return M.root_for_path(name)
end

function M.set_active_for_buf(bufnr, opts)
	local match = M.root_for_buf(bufnr)
	if not match then
		vim.notify("Current buffer is not inside a workspace root", vim.log.levels.WARN)
		return nil
	end
	return M.set_active(match.index, opts or { reason = "buffer_root" })
end

function M.sync(opts)
	opts = opts or {}
	local active = active_root()
	if not active then
		return
	end

	vim.cmd("lcd " .. vim.fn.fnameescape(active.path))
	if opts.sync_tree ~= false then
		require("workspace.ui").sync_tree(active.path)
	end
	pcall(function()
		require("lualine").refresh()
	end)
end

function M.set_active(target, opts)
	opts = opts or {}
	local next_index = find_root(target)
	if not next_index then
		vim.notify("Workspace root not found: " .. tostring(target), vim.log.levels.WARN)
		return nil
	end

	local previous = active_root()
	state.active_index = next_index
	local current = active_root()

	if opts.sync ~= false then
		M.sync({ sync_tree = opts.sync_tree })
	end

	if not previous or previous.path ~= current.path then
		emit("WorkspaceRootChanged", {
			workspace_file = state.workspace_file,
			workspace_name = state.name,
			previous_root = previous and previous.path or nil,
			previous_root_name = previous and previous.name or nil,
			active_root = current.path,
			active_root_name = current.name,
			reason = opts.reason or "set_active",
		})
	end

	return vim.deepcopy(current)
end

function M.next_root()
	if #state.roots == 0 then
		return nil
	end
	local next_index = ((state.active_index or 1) % #state.roots) + 1
	return M.set_active(next_index, { reason = "next_root" })
end

function M.prev_root()
	if #state.roots == 0 then
		return nil
	end
	local next_index = (state.active_index or 1) - 1
	if next_index < 1 then
		next_index = #state.roots
	end
	return M.set_active(next_index, { reason = "prev_root" })
end

function M.open(workspace_file, opts)
	opts = opts or {}
	local parsed = parse_workspace_file(workspace_file)
	state.workspace_file = parsed.workspace_file
	state.name = parsed.name
	state.roots = parsed.roots
	state.active_index = nil

	local initial_target = opts.active_root or 1
	M.set_active(initial_target, {
		sync = opts.sync ~= false,
		reason = opts.reason or "open_workspace",
		sync_tree = opts.sync_tree,
	})

	emit("WorkspaceOpened", {
		workspace_file = state.workspace_file,
		workspace_name = state.name,
		active_root = M.active_dir(),
		root_count = #state.roots,
	})

	return M.get()
end

function M.close()
	if not M.is_open() then
		return
	end
	local closed = M.get()
	state.workspace_file = nil
	state.name = nil
	state.roots = {}
	state.active_index = nil
	pcall(function()
		require("lualine").refresh()
	end)
	emit("WorkspaceClosed", closed)
end

function M.session_data()
	if not M.is_open() then
		return nil
	end
	local active = active_root()
	if not active then
		return nil
	end
	return vim.json.encode({
		workspace_file = state.workspace_file,
		active_root = active.path,
	})
end

function M.restore_session_data(extra_data)
	if type(extra_data) ~= "string" or extra_data == "" then
		return
	end
	local decoded = vim.json.decode(extra_data)
	if type(decoded) ~= "table" or type(decoded.workspace_file) ~= "string" then
		return
	end
	local ok, err = pcall(function()
		M.open(decoded.workspace_file, {
			active_root = decoded.active_root,
			sync = false,
			reason = "session_restore",
		})
		vim.schedule(function()
			M.sync({ sync_tree = true })
		end)
	end)
	if not ok then
		vim.notify("Failed to restore workspace session data: " .. err, vim.log.levels.WARN)
	end
	return err
end

function M.statusline()
	local active = active_root()
	if not active then
		return ""
	end
	return string.format("WS:%s(%d)", active.name, #state.roots)
end

local function prompt_workspace_file()
	local initial = vim.fn.getcwd(-1, -1) .. "/"
	local input = vim.fn.input("Workspace file: ", initial, "file")
	if input == nil or input == "" then
		return
	end
	local ok, err = pcall(M.open, input)
	if not ok then
		vim.notify(err, vim.log.levels.ERROR)
	end
end

function M.setup()
	if setup_done then
		return M
	end
	setup_done = true

	vim.api.nvim_create_user_command("WorkspaceOpen", function(opts)
		local ok, err
		if opts.args == "" then
			prompt_workspace_file()
			return
		end
		ok, err = pcall(M.open, opts.args)
		if not ok then
			vim.notify(err, vim.log.levels.ERROR)
		end
	end, {
		nargs = "?",
		complete = "file",
		desc = "Open a .code-workspace manifest",
	})

	vim.api.nvim_create_user_command("WorkspaceClose", function()
		M.close()
	end, { desc = "Close the active workspace manifest" })

	vim.api.nvim_create_user_command("WorkspaceRoot", function()
		require("workspace.ui").pick_root()
	end, { desc = "Select the active workspace root" })

	vim.api.nvim_create_user_command("WorkspaceNextRoot", function()
		M.next_root()
	end, { desc = "Select the next workspace root" })

	vim.api.nvim_create_user_command("WorkspacePrevRoot", function()
		M.prev_root()
	end, { desc = "Select the previous workspace root" })

	vim.api.nvim_create_user_command("WorkspaceFiles", function()
		require("workspace.ui").workspace_files()
	end, { desc = "Find files across all workspace roots" })

	vim.api.nvim_create_user_command("WorkspaceBuffers", function()
		require("workspace.ui").workspace_buffers()
	end, { desc = "List buffers across all workspace roots" })

	vim.api.nvim_create_user_command("WorkspaceGrep", function()
		require("workspace.ui").workspace_grep()
	end, { desc = "Grep across all workspace roots" })

	vim.api.nvim_create_user_command("WorkspaceBufferRoot", function()
		M.set_active_for_buf(0, { reason = "buffer_root", sync_tree = true })
	end, { desc = "Set the active workspace root from the current buffer" })

	vim.api.nvim_create_user_command("WorkspaceSync", function()
		M.sync({ sync_tree = true })
	end, { desc = "Re-sync cwd, Neo-tree, and statusline to the active workspace root" })

	local map = vim.keymap.set
	map("n", "<leader>wo", prompt_workspace_file, { desc = "Open workspace manifest" })
	map("n", "<leader>wr", function()
		require("workspace.ui").pick_root()
	end, { desc = "Pick workspace root" })
	map("n", "<leader>wh", function()
		M.set_active_for_buf(0, { reason = "buffer_root", sync_tree = true })
	end, { desc = "Use current buffer root" })
	map("n", "<leader>wn", function()
		M.next_root()
	end, { desc = "Next workspace root" })
	map("n", "<leader>wp", function()
		M.prev_root()
	end, { desc = "Previous workspace root" })
	map("n", "<leader>wb", function()
		require("workspace.ui").workspace_buffers()
	end, { desc = "Workspace buffers" })
	map("n", "<leader>wf", function()
		require("workspace.ui").workspace_files()
	end, { desc = "Workspace files" })
	map("n", "<leader>wg", function()
		require("workspace.ui").workspace_grep()
	end, { desc = "Workspace grep" })
	map("n", "<leader>ws", function()
		M.sync({ sync_tree = true })
	end, { desc = "Sync workspace root" })

	return M
end

return M.setup()
