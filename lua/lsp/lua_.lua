return {
	server_name = "lua_ls",
	dependencies = {
		{
			"folke/lazydev.nvim",
			dependencies = {
				"rcarriga/nvim-dap-ui",
			},
			ft = "lua", -- only load on lua files
			opts = {
				library = {
					-- See the configuration section for more details
					-- Load luvit types when the `vim.uv` word is found
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
					"nvim-dap-ui",
				},
			},
		},
	},
	formatter = { lua = { "stylua" } },
	opts = {
		settings = {
			Lua = {
				diagnostics = {
					globals = { "vim", "Snacks" },
				},
				workspace = {
					library = {
						[vim.fn.expand("$VIMRUNTIME/lua")] = true,
						[vim.fn.stdpath("config") .. "/lua"] = true,
					},
				},
			},
		},
	},
	lspconfig = function(_, opts)
		local old_on_attach = opts.on_attach
		opts.on_attach = function(client, bufnr)
			client.server_capabilities.documentFormattingProvider = false
			old_on_attach(client, bufnr)
		end

		-- Define server config using new API
		-- mason-lspconfig will automatically call vim.lsp.enable('lua_ls')
		vim.lsp.config('lua_ls', opts)
	end,
}
