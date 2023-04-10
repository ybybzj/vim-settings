local handlers = require("my.lsp.handlers")

return {
	on_attach = function(client, bufnr)
		client.server_capabilities.semanticTokensProvider = false
		handlers.lsp_keymaps(client, bufnr)
	end,
}
