local map = vim.keymap.set

-- leader key
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- source code
map("n", "<leader><leader>x", "<cmd>source %<cr>", { desc = "Source current file" })
map("n", "<leader>x", ":.lua<cr>", { desc = "Execute current line as Lua" })
map("v", "<leader>x", ":lua<cr>", { desc = "Execute selection as Lua" })

map("n", "<leader>q", ":copen<cr>", { desc = "Open quickfix list" })
map("n", "<leader>cd", ":cd %:p:h<cr>", { desc = "Change to current file directory" })

-- File path shortcuts (cmdline)
vim.keymap.set("c", "%%", function()
	return vim.fn.fnameescape(vim.fn.expand("%:h")) .. "/"
end, { expr = true, desc = "Insert current file directory" })
map("n", "<leader>ew", ":e <C-r>=fnameescape(expand('%:h')).'/'<cr>", { desc = "Edit file in current directory" })
map("n", "<leader>es", ":sp <C-r>=fnameescape(expand('%:h')).'/'<cr>", { desc = "Split file in current directory" })
map("n", "<leader>ev", ":vsp <C-r>=fnameescape(expand('%:h')).'/'<cr>", { desc = "Vsplit file in current directory" })

-- Save and quit
map("n", "<M-s>", "<Esc>:wa<cr><Esc>", { desc = "Save all files" })
map("i", "<M-s>", "<Esc>:wa<cr>", { desc = "Save all files" })
map("n", "<M-q>", "<Esc>:q<cr>", { desc = "Quit window" })
map("n", "<M-Q>", "<Esc>:qa<cr>", { desc = "Quit all" })
map("n", "<leader>ct", "<Esc>:tabclose<cr>", { desc = "Close tab" })

-- Navigation
map("n", "<cr>", ":noh<cr><cr>", { desc = "Clear search highlight" })
map("n", "<Up>", "gk", { desc = "Move up (display line)" })
map("n", "<Down>", "gj", { desc = "Move down (display line)" })

-- Copy/paste with system clipboard
map("v", "<M-c>", '"+y<cr>', { desc = "Copy to system clipboard" })
map("n", "<M-v>", '"+P<cr>', { desc = "Paste from system clipboard" })
map("v", "<M-v>", '"+P<cr>', { desc = "Paste from system clipboard" })

local function current_file_label()
	local name = vim.api.nvim_buf_get_name(0)
	if name == "" then
		return "[No Name]"
	end

	return vim.fn.fnamemodify(name, ":p")
end

local function current_real_file_path()
	if vim.bo.buftype ~= "" then
		return nil
	end

	local name = vim.api.nvim_buf_get_name(0)
	if name == "" then
		return nil
	end

	local path = vim.fn.fnamemodify(name, ":p")
	local stat = vim.uv.fs_stat(path)
	if not stat or stat.type ~= "file" then
		return nil
	end

	return vim.uv.fs_realpath(path) or path
end

local function copy_current_file_path()
	local path = current_real_file_path()
	if not path then
		vim.notify("Current buffer has no real local file path", vim.log.levels.WARN)
		return
	end

	vim.fn.setreg("+", path)
	vim.notify("Copied file path: " .. path)
end

local function normalize_range(start_line, start_col, end_line, end_col)
	if start_line > end_line or (start_line == end_line and start_col > end_col) then
		return end_line, end_col, start_line, start_col
	end

	return start_line, start_col, end_line, end_col
end

local function selected_text_and_range(mode)
	local start_pos = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")
	local start_line, start_col, end_line, end_col = normalize_range(start_pos[2], start_pos[3], end_pos[2], end_pos[3])

	if mode == "V" then
		local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
		return table.concat(lines, "\n"), string.format("%d-%d", start_line, end_line)
	end

	if mode == "\22" then
		local lines = {}
		for line = start_line, end_line do
			local text = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1] or ""
			lines[#lines + 1] = string.sub(text, start_col, end_col)
		end
		return table.concat(lines, "\n"), string.format("%d:%d-%d:%d", start_line, start_col, end_line, end_col)
	end

	-- Characterwise visual marks are inclusive, while nvim_buf_get_text() uses an exclusive end column.
	local lines = vim.api.nvim_buf_get_text(0, start_line - 1, start_col - 1, end_line - 1, end_col, {})
	return table.concat(lines, "\n"), string.format("%d:%d-%d:%d", start_line, start_col, end_line, end_col)
end

local function copy_context()
	local mode = vim.fn.mode()
	local text, range

	if mode == "v" or mode == "V" or mode == "\22" then
		text, range = selected_text_and_range(mode)
	else
		local line = vim.api.nvim_win_get_cursor(0)[1]
		text = vim.api.nvim_buf_get_lines(0, line - 1, line, false)[1] or ""
		range = tostring(line)
	end

	local payload = string.format("here is the code snippet at: %s:%s\n\n%s\n", current_file_label(), range, text)
	vim.fn.setreg("+", payload)
	vim.notify("Copied context: " .. current_file_label() .. ":" .. range)
end

map({ "n", "v" }, "<leader>cc", copy_context, { desc = "Copy code context" })
map({ "n", "v" }, "<space>cc", copy_context, { desc = "Copy code context" })
map("n", "<space>cf", copy_current_file_path, { desc = "Copy current file path" })

-- Move lines up/down
map("n", "<M-Up>", ":m .-2<CR>==", { noremap = true, silent = true, desc = "Move line up" })
map("n", "<M-Down>", ":m .+1<CR>==", { noremap = true, silent = true, desc = "Move line down" })
map("v", "<M-Up>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move selection up" })
map("v", "<M-Down>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move selection down" })
