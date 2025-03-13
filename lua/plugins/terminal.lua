function _G.set_terminal_keymaps()
	local opts = { buffer = 0 }
	vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
	-- vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
	-- vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], opts)
	-- vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], opts)
	-- vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], opts)
	-- vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], opts)
	-- vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], opts)
end

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
			})
			local Terminal = require("toggleterm.terminal").Terminal
			local git_term = Terminal:new({
				display_name = "Lazygit",
				cmd = "lazygit",
				hidden = true,
				hide_numbers = true,
				shade_filetypes = {},
				shade_terminals = true,
				shading_factor = 2,
				start_in_insert = true,
				insert_mappings = true,
				persist_size = true,
				direction = "tab",
				close_on_exit = true,
				shell = vim.o.shell,
				float_opts = {
					border = "single",
					winblend = 0,
					highlights = {
						border = "Normal",
						background = "Normal",
					},
				},
			})

			_toggle_lazygit = function()
				git_term:toggle()
			end

			vim.cmd("autocmd! TermOpen term://* lua set_terminal_keymaps()")
		end,
		keys = {
			{ "<space>gg", "<cmd>lua _toggle_lazygit()<CR>", desc = "GitUI" },
			{ "<leader>gg", "<cmd>lua _toggle_lazygit()<CR>", desc = "GitUI" },
			{
				"<C-\\>",
				"<cmd>ToggleTerm<cr>",
				desc = "Toggle Terminal",
			},
		},
	},
}
