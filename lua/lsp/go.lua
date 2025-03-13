return {
	server_name = "gopls",
	dependencies = {
		{
			"ray-x/go.nvim",
			config = function()
				require("go").setup()
			end,
			event = { "CmdlineEnter" },
			ft = { "go", "gomod" },
		},
	},
	opts = {},
	-- lspconfig = function(lspconfig, opts)
	-- 	local old_on_attach = opts.on_attach
	-- 	opts.on_attach = function(client, bufnr)
	-- 		client.server_capabilities.documentFormattingProvider = false
	--
	-- 		old_on_attach(client, bufnr)
	-- 	end
	-- 	lspconfig.gopls.setup(opts)
	-- end,
}
