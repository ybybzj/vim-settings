local handlers = require("my.lsp.handlers")
return {
	settings = {
		args = {},
	},
	on_attach = function(client, bufnr)
		client.server_capabilities.documentFormattingProvider = false
		handlers.on_attach(client, bufnr)
	end,
}
