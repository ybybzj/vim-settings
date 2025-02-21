local default_keymaps = {
	["?"] = {
		cmd = "<cmd>Lspsaga peek_definition<CR>",
	},
	["gd"] = {
		cmd = "<cmd>Lspsaga goto_definition<CR>",
	},
	["gr"] = {
		cmd = "<cmd>lua Snacks.picker.lsp_references()<cr>",
	},
	["gs"] = {
		cmd = "<cmd>lua Snacks.picker.lsp_symbols()<cr>",
	},
	["K"] = {
		cmd = "<Cmd>Lspsaga hover_doc<CR>",
	},
	["<C-k>"] = {
		cmd = "<cmd>lua vim.lsp.buf.document_highlight()<CR>",
	},
	["<F2>"] = {
		cmd = "<cmd>Lspsaga rename<CR>",
	},
	["ge"] = {
		cmd = "<cmd>Lspsaga show_line_diagnostics<CR>",
	},
}

return default_keymaps
