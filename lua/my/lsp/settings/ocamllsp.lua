local handlers = require("my.lsp.handlers")

return {
	on_attach = function(client, bufnr)
		handlers.on_attach(client, bufnr)
		handlers.lsp_codelens()
	end,
}
