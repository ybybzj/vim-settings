local handlers = require("my.lsp.handlers")

return {
	on_attach = function(_, bufnr)
		handlers.lsp_keymaps(bufnr)
	end,
}
