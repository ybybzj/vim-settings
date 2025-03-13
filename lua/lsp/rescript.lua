return {
	server_name = "rescriptls",
	dependencies = {
		{
			"aspeddro/rescript-tools.nvim",
		},
	},

	opts = {
		cmd = { "rescript-language-server", "--stdio" },
		init_options = {
			extensionConfiguration = {
				-- need @rescript/language-server >=1.44.0
				incrementalTypechecking = {
					enabled = true,
				},
			},
		},
	},

	lspconfig = function(lspconfig, opts)
		local old_on_attach = opts.on_attach
		opts.on_attach = function(client, bufnr)
			client.server_capabilities.semanticTokensProvider = false
			old_on_attach(client, bufnr)
		end

		opts.commands = {
			ResOpenCompiled = {
				require("rescript-tools").open_compiled,
				description = "Open Compiled JS",
			},
			ResCreateInterface = {
				require("rescript-tools").create_interface,
				description = "Create Interface file",
			},
			ResSwitchImplInt = {
				require("rescript-tools").switch_impl_intf,
				description = "Switch Implementation/Interface",
			},
		}
		lspconfig.rescriptls.setup(opts)
	end,
}
