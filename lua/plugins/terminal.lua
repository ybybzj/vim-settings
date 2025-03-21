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
					if term.display_name ~= "Lazygit" then
						vim.api.nvim_buf_set_keymap(
							term.bufnr,
							"t",
							"<esc>",
							[[<C-\><C-n>]],
							{ noremap = true, silent = true }
						)
					end
				end,
			})
			local Terminal = require("toggleterm.terminal").Terminal
			local git_term = Terminal:new({
				display_name = "Lazygit",
				cmd = "lazygit",
				hidden = true,
				hide_numbers = true,
				start_in_insert = true,
				insert_mappings = true,
				persist_size = true,
				direction = "float",
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
