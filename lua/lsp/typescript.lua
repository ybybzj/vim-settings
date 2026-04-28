return {
	server_name = "vtsls",
	debugger_name = "js-debug-adapter",
	dependencies = {
		{
			"dmmulroy/tsc.nvim",
			opts = {},
		},
		{
			"mfussenegger/nvim-lint",
		},
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
					variableTypes = { enabled = false },
					propertyDeclarationTypes = { enabled = true },
					functionLikeReturnTypes = { enabled = true },
					enumMemberValues = { enabled = true },
				},
			},
		},
	},
	lspconfig = function(_, opts)
		local old_on_attach = opts.on_attach
		opts.on_attach = function(client, bufnr)
			client.server_capabilities.documentFormattingProvider = false
			client.server_capabilities.documentRangeFormattingProvider = false
			-- no default maps, so you may want to define some here

			old_on_attach(client, bufnr)
		end

		-- Setup nvim-vtsls plugin (provides helper commands)
		local vtsls = require("vtsls")
		vtsls.config({
			refactor_auto_rename = true,
		})

		-- Define server config using new API
		-- mason-lspconfig will automatically call vim.lsp.enable('vtsls')
		vim.lsp.config('vtsls', opts)

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
