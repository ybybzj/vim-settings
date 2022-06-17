local handlers = require("my.lsp.handlers")
return {
	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
		},
	},
	on_attach = function(client, bufnr)
		client.resolved_capabilities.document_formatting = false
		handlers.on_attach(client, bufnr)
	end,
}
