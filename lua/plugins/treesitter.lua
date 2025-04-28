return {
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		build = ":TSUpdate",
		config = function()
			local configs = require("nvim-treesitter.configs")

			configs.setup({
				ensure_installed = {
					"lua",
				},
				sync_install = false,
				highlight = { enable = true },
				indent = { enable = true },

				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "gv",
						node_incremental = "]",
						scope_incremental = "}",
						node_decremental = "[",
					},
				},
				matchup = { enable = true },
				autopairs = { enable = true },
				textobjects = {
					select = {
						enabled = false,
					},
					move = {
						enable = true,
						set_jumps = true, -- whether to set jumps in the jumplist
						goto_next_start = {
							["]B"] = "@block.outer",
							["]M"] = "@function.outer",
							["]["] = "@class.outer",
						},
						goto_next_end = {
							["]b"] = "@block.outer",
							["]m"] = "@function.outer",
							["]]"] = "@class.outer",
						},
						goto_previous_start = {
							["[b"] = "@block.inner",
							["[m"] = "@function.inner",
							["[["] = "@class.inner",
						},
						goto_previous_end = {
							["[B"] = "@block.outer",
							["[M"] = "@function.outer",
							["[]"] = "@class.outer",
						},
					},
				},
			})
		end,
	},
	{
		"echasnovski/mini.ai",
		version = "*",
		opts = {},
		config = function()
			local mini_ai = require("mini.ai")
			local spec_treesitter = mini_ai.gen_spec.treesitter
			mini_ai.setup({
				custom_textobjects = {
					f = spec_treesitter({ a = "@function.outer", i = "@function.inner" }),
					c = spec_treesitter({
						a = { "@call.outer" },
						i = { "@call.inner" },
					}),
					a = spec_treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
				},
			})
		end,
	},
	"JoosepAlviste/nvim-ts-context-commentstring",
}
