return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		config = function()
			require("toggleterm").setup({
				size = function(term)
					if term.direction == "horizontal" then
						return 15
					elseif term.direction == "vertical" then
						return vim.o.columns * 0.4
					end
				end,
				direction = "horizontal",
				close_on_exit = true,
				on_open = function(term)
					vim.api.nvim_buf_set_keymap(
						term.bufnr,
						"t",
						"<esc>",
						[[<C-\><C-n>]],
						{ noremap = true, silent = true }
					)
				end,
			})
		end,
		keys = {
			{
				"<C-\\>",
				"<cmd>ToggleTerm<cr>",
				desc = "Toggle Terminal",
			},
		},
	},
}
