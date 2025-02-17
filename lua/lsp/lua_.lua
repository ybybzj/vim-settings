return {
	server_name = "lua_ls",
	dependencies = {
		{
			"folke/lazydev.nvim",
			ft = "lua", -- only load on lua files
			opts = {
				library = {
					-- See the configuration section for more details
					-- Load luvit types when the `vim.uv` word is found
					{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
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
	lspconfig = function(lspconfig, opts)
		local old_on_attach = opts.on_attach
		opts.on_attach = function(client, bufnr)
			client.server_capabilities.documentFormattingProvider = false
			old_on_attach(client, bufnr)
		end

		lspconfig.lua_ls.setup(opts)
	end,
}
