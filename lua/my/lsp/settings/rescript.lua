local handlers = require("my.lsp.handlers")

return {
	on_attach = function(client, bufnr)
		handlers.lsp_keymaps(client, bufnr)
	end,
}
