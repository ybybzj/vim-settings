local default_keymaps = {
	["?"] = {
		cmd = "<cmd>Lspsaga peek_definition<CR>",
	},
	["gd"] = {
		cmd = "<cmd>lua Snacks.picker.lsp_definitions()<CR>",
	},
	["gD"] = {
		cmd = "<cmd>lua Snacks.picker.lsp_declarations()<CR>",
	},
	["gi"] = {
		cmd = "<cmd>lua Snacks.picker.lsp_implementations()<CR>",
	},
	["gt"] = {
		cmd = "<cmd>lua Snacks.picker.lsp_type_definitions()<CR>",
	},
	["gr"] = {
		cmd = "<cmd>lua Snacks.picker.lsp_references()<cr>",
	},
	["gs"] = {
		cmd = "<cmd>lua Snacks.picker.lsp_symbols()<cr>",
	},
	["K"] = {
		cmd = '<cmd>lua vim.lsp.buf.hover({border = "rounded",})<CR>',
		-- cmd = "<cmd>Lspsaga hover_doc<CR>",
	},
	["<C-k>"] = {
		cmd = "<cmd>lua vim.lsp.buf.document_highlight()<CR>",
	},
	["<F2>"] = {
		cmd = "<cmd>lua vim.lsp.buf.rename()<CR>",
	},
	["ge"] = {
		cmd = "<cmd>lua vim.diagnostic.open_float()<CR>",
		-- cmd = "<cmd>Lspsaga show_line_diagnostics<CR>",
	},
}

return default_keymaps
