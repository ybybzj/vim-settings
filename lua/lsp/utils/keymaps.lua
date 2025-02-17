local default_keymaps = {
	["?"] = {
		cmd = "<Cmd>Lspsaga peek_definition<CR>",
	},
	["gd"] = {
		cmd = "<Cmd>Lspsaga goto_definition<CR>",
	},
	["gr"] = {
		cmd = "<Cmd>Lspsaga finder<CR>",
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
