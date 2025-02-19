return {
	server_name = "vtsls",
	dependencies = {
		{
			"dmmulroy/tsc.nvim",
			opts = {},
		},
		-- {
		-- 	"pmizio/typescript-tools.nvim",
		-- 	dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		-- 	opts = {},
		-- },
		{
			"yioneko/nvim-vtsls",
		},
	},
	formatter = {
		javascript = { "prettierd", "prettier" },
		typescript = { "prettierd", "prettier" },
		javascriptreact = { "prettierd", "prettier" },
		typescriptreact = { "prettierd", "prettier" },
	},
	linter = {
		javascript = { "eslint" },
		typescript = { "eslint" },
	},
	opts = {
		settings = {
			javascript = {
				preferences = {
					importModuleSpecifier = "relative",
				},
			},
			typescript = {
				preferences = {
					importModuleSpecifier = "relative",
				},
				inlayHints = {
					parameterNames = { enabled = "literals" },
					parameterTypes = { enabled = true },
					variableTypes = { enabled = true },
					propertyDeclarationTypes = { enabled = true },
					functionLikeReturnTypes = { enabled = true },
					enumMemberValues = { enabled = true },
				},
			},
		},
	},
	lspconfig = function(lspconfig, opts)
		local old_on_attach = opts.on_attach
		opts.on_attach = function(client, bufnr)
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false
			-- no default maps, so you may want to define some here

			old_on_attach(client, bufnr)
		end

		local vtsls = require("vtsls")
		vtsls.config({
			refactor_auto_rename = true,
		})
		require("lspconfig.configs").vtsls = vtsls.lspconfig
		lspconfig.vtsls.setup(opts)

		-- setup comment
		local comment = require("Comment")
		comment.setup({
			pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
		})
	end,
	keys = {
		["<space>oi"] = {
			cmd = ":VtsExec organize_imports<CR>",
		},
		["<space>rf"] = {
			cmd = ":VtsExec rename_file<CR>",
		},
		["<space>st"] = {
			cmd = ":VtsExec select_ts_version<CR>",
		},
		["<space>fr"] = {
			cmd = ":VtsExec file_references<CR>",
		},
	},
}
