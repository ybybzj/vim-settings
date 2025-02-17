-- Highlight when yanking (copying) text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("my/highlighting-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
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
