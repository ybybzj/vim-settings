-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("my/highlighting-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

local last_checktime_ns = 0
local checktime_interval_ns = 500 * 1000 * 1000
local uv = vim.uv or vim.loop

local function check_focused_buffer_time(args)
	local bufnr = args.buf and args.buf > 0 and args.buf or vim.api.nvim_get_current_buf()
	if vim.fn.mode() == "c" or vim.bo[bufnr].buftype ~= "" then
		return
	end

	local now = uv.hrtime()
	if now - last_checktime_ns < checktime_interval_ns then
		return
	end
	last_checktime_ns = now

	-- `autoread` only reloads after Neovim checks file timestamps. Trigger it
	-- for the focused normal buffer so external edits show up without toggling.
	vim.cmd("silent! checktime " .. bufnr)
end

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "CursorMoved", "CursorMovedI" }, {
	desc = "Reload focused buffer after external file changes",
	group = vim.api.nvim_create_augroup("my/focused-buffer-autoread", { clear = true }),
	callback = check_focused_buffer_time,
})

-- vim.api.nvim_create_user_command("CloseFloatingWindows", function(opts)
-- 	for _, window_id in ipairs(vim.api.nvim_list_wins()) do
-- 		-- If window is floating
-- 		if vim.api.nvim_win_get_config(window_id).relative ~= "" then
-- 			-- Force close if called with !
-- 			vim.api.nvim_win_close(window_id, opts.bang)
-- 		end
-- 	end
-- end, { bang = true, nargs = 0 })
