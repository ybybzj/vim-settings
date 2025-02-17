local settings = require("lsp.utils.loader").load()

local toggle_virtlines = "<cmd>lua require('lsp.utils.handlers').toggle_virtlines()<cr>"

return {
	{
		"williamboman/mason.nvim",
		opts = {},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
		},
		opts = {
			ensure_installed = settings.server_names(),
			automatic_installation = false,
		},
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- formatter
			{
				"stevearc/conform.nvim",
				event = { "BufReadPre", "BufNewFile" },
				keys = {
					{
						"<F5>",
						"<cmd>lua require('conform').format({lsp_fallback=true})<cr>",
						desc = "Format buffer",
					},
				},
			},
			-- linter
			{
				"mfussenegger/nvim-lint",
				event = { "BufReadPre", "BufNewFile" },
				init = function()
					vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost" }, {
						callback = function()
							local lint_status, lint = pcall(require, "lint")
							if lint_status then
								lint.try_lint()
							end
						end,
					})
				end,
			},
			-- comment
			{
				"numToStr/Comment.nvim",
				config = function()
					local comment = require("Comment")
					comment.setup({
						pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
					})

					local ft = require("Comment.ft")

					-- set both line and block commentstring
					ft.set("rescript", { "//%s", "/*%s*/" })
				end,
			},

			-- diagnostic
			{
				"folke/trouble.nvim",
				opts = {},
				cmd = "Trouble",
			},
			-- ui
			{
				"nvimdev/lspsaga.nvim",
				event = "LspAttach",
				dependencies = {
					"nvim-treesitter/nvim-treesitter", -- optional
					"nvim-tree/nvim-web-devicons", -- optional
				},
				init = function()
					local signs = {
						{ name = "DiagnosticSignError", text = "" },
						{ name = "DiagnosticSignWarn", text = "" },
						{ name = "DiagnosticSignHint", text = "" },
						{ name = "DiagnosticSignInfo", text = "" },
					}

					for _, sign in ipairs(signs) do
						vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
					end

					local config = {
						-- disable virtual text
						virtual_text = false,
						-- show signs
						signs = {
							active = signs,
						},
						update_in_insert = true,
						underline = true,
						severity_sort = true,
						float = {
							focusable = false,
							style = "minimal",
							border = "rounded",
							source = "always",
							header = "",
							prefix = "",
						},
					}

					vim.diagnostic.config(config)
				end,
				opts = {
					diagnostic = {
						diagnostic_only_current = true,
						keys = {
							exec_action = "<CR>",
							toggle_or_jump = "<space>",
						},
					},

					finder = {
						default = "def+ref+imp",
						keys = {
							toggle_or_open = "<CR>",
						},
					},
				},
			},

			"saghen/blink.cmp",
			settings.dependencies(),
		},

		config = function()
			-- setup lspconfig
			local lspconfig = require("lspconfig")
			settings.lspconfig(lspconfig)

			-- setup formatters
			local conform = require("conform")
			local formatters = settings.formatters()
			conform.setup({
				formatters_by_ft = formatters,
				format_on_save = {
					-- I recommend these options. See :help conform.format for details.
					lsp_format = "fallback",
					timeout_ms = 500,
				},
				notify_on_error = true,
			})
			settings.formatters_setup(conform)

			-- setup linters
			local nvim_lint = require("lint")
			nvim_lint.linters_by_ft = settings.linters()
		end,
		keys = {
			{
				"<F8>",
				"<cmd>Lspsaga diagnostic_jump_next<cr>",
				desc = "Goto next diagnostic",
			},
			{ "<F7>", "<cmd>Lspsaga diagnostic_jump_prev<cr>", desc = "Goto prev diagnostic" },
			{
				"<space>ld",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "toggle workspace diagnostics",
			},
			{ "<space>la", "<cmd>Lspsaga code_action<cr>", desc = "list code actions" },
			{ "<space>lf", "<cmd>lua vim.lsp.buf.format()<cr>", desc = "format document" },
			{ "<space>lo", "<cmd>Lspsaga outline<cr>", desc = "toggle outline" },
			{ "<space>o", "<cmd>Lspsaga outline<cr>", desc = "Toogle Lsp Outline" },
			{ "<space>lt", toggle_virtlines, desc = "toggle type hint" },
			{ "<F4>", toggle_virtlines, mode = "n", desc = "toggle type hint" },
		},
	},
}
