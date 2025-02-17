return {
	server_name = "zls",
	dependencies = {
		{
			"ziglang/zig.vim",
			config = function()
				vim.g.zig_std_dir = "/Users/jackzj/.zvm/bin/lib/std"
			end,
		},
	},

	lspconfig = function(lspconfig, opts)
		local old_on_attach = opts.on_attach
		opts.on_attach = function(client, bufnr)
			client.server_capabilities.documentFormattingProvider = false

			old_on_attach(client, bufnr)
		end
		lspconfig.zls.setup(opts)
	end,
}
