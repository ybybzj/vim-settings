return {
	server_name = "ts_ls",
	dependencies = {
		{
			"dmmulroy/tsc.nvim",
			opts = {},
		},
		{
			"pmizio/typescript-tools.nvim",
			dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
			opts = {},
		},
	},
	formatter = {
		javascript = { "prettier" },
		typescript = { "prettier" },
		javascriptreact = { "prettier" },
		typescriptreact = { "prettier" },
	},
	linter = {
		javascript = { "eslint" },
		typescript = { "eslint" },
	},
	opts = {
		settings = {
			expose_as_code_action = "all",
			tsserver_file_preferences = {
				importModuleSpecifierPreference = "relative",
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
		require("typescript-tools").setup(opts)
	end,
	keys = {
		["<space>oi"] = {
			cmd = ":TSToolsOrganizeImports<CR>",
		},
		["<space>rf"] = {
			cmd = ":TSToolsRenameFile<CR>",
		},
	},
}
