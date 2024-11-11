local handlers = require("my.lsp.handlers")

require("tsc").setup()

return {
	on_attach = function(client, bufnr)
		client.server_capabilities.documentFormattingProvider = false
		client.server_capabilities.documentRangeFormattingProvider = false
		-- no default maps, so you may want to define some here
		vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>oi", ":TSToolsOrganizeImports<CR>", { silent = true })
		vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>rf", ":TSToolsRenameFile<CR>", { silent = true })

		handlers.on_attach(client, bufnr)
	end,
	settings = {
		expose_as_code_action = "all",
		tsserver_file_preferences = {
			importModuleSpecifierPreference = "relative",
		},
	},
}
