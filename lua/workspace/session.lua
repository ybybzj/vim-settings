local M = {}

local function get_auto_session()
	local ok, auto_session = pcall(require, "auto-session")
	if ok then
		return auto_session
	end
	return nil
end

local function decode_extra_data(raw)
	if type(raw) ~= "string" or raw == "" then
		return nil
	end
	local ok, chunk = pcall(load, "return " .. raw)
	if not ok or type(chunk) ~= "function" then
		return nil
	end
	local success, value = pcall(chunk)
	if success and type(value) == "string" then
		return value
	end
	return nil
end

local function extra_file_for(session_file)
	return session_file:gsub("%.vim$", "x.vim")
end

local function read_workspace_metadata(session_file)
	if type(session_file) ~= "string" or session_file == "" then
		return nil
	end
	local extra_file = extra_file_for(session_file)
	if vim.fn.filereadable(extra_file) ~= 1 then
		return nil
	end
	for _, line in ipairs(vim.fn.readfile(extra_file)) do
		local raw = line:match("restore_extra_data%((.+)%)")
		if raw then
			local decoded = decode_extra_data(raw)
			if decoded then
				local ok, data = pcall(vim.json.decode, decoded)
				if ok and type(data) == "table" then
					return data
				end
			end
		end
	end
	return nil
end

local function current_session_metadata()
	if vim.v.this_session == nil or vim.v.this_session == "" then
		return nil
	end
	return read_workspace_metadata(vim.v.this_session)
end

local function workspace_preview_lines(session_name, metadata)
	local lines = { "Session: " .. session_name }
	if not metadata then
		lines[#lines + 1] = "Workspace: none"
		return lines
	end
	local workspace_file = metadata.workspace_file or ""
	local active_root = metadata.active_root or ""
	lines[#lines + 1] = "Workspace: " .. (workspace_file ~= "" and vim.fn.fnamemodify(workspace_file, ":t") or "unknown")
	if workspace_file ~= "" then
		lines[#lines + 1] = "Manifest: " .. workspace_file
	end
	if active_root ~= "" then
		lines[#lines + 1] = "Active root: " .. active_root
	end
	return lines
end

function M.save()
	local ok, workspace = pcall(require, "workspace")
	if not ok then
		return nil
	end
	return workspace.session_data()
end

function M.pre_save()
	local ok, workspace = pcall(require, "workspace")
	if ok and workspace.is_open() then
		workspace.sync({ sync_tree = false })
	end
	return true
end

function M.post_restore()
	local ok, workspace = pcall(require, "workspace")
	if not ok then
		return
	end
	local metadata = current_session_metadata()
	if not metadata then
		if workspace.is_open() then
			workspace.close()
		end
		return
	end
	if workspace.is_open() then
		vim.schedule(function()
			workspace.sync({ sync_tree = true })
		end)
	end
end

function M.search()
	local auto_session = get_auto_session()
	if auto_session then
		auto_session.search()
	end
end

function M.restore(session_name, extra_data)
	if type(extra_data) == "string" and extra_data ~= "" then
		local ok, workspace = pcall(require, "workspace")
		if ok then
			workspace.restore_session_data(extra_data)
		end
		return
	end
	local auto_session = get_auto_session()
	if auto_session then
		auto_session.restore_session(session_name)
	end
end

function M.preview(session_name, session_filename, session_lines)
	local auto_session = get_auto_session()
	if not auto_session then
		return session_lines, "vim"
	end
	local session_root = auto_session.get_root_dir()
	local session_file = session_root .. session_filename
	local metadata = read_workspace_metadata(session_file)
	local lines = workspace_preview_lines(session_name, metadata)
	lines[#lines + 1] = ""
	local lib = require("auto-session.lib")
	local summary = lib.create_session_summary(session_file)
	local formatted = lib.format_session_summary(summary)
	vim.list_extend(lines, vim.split(formatted, "\n"))
	return lines, "markdown"
end

return M
