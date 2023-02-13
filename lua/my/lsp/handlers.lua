local M = {}

M.setup = function()
	local signs = {
		{ name = "DiagnosticSignError", text = "" },
		{ name = "DiagnosticSignWarn", text = "" },
		{ name = "DiagnosticSignHint", text = "" },
		{ name = "DiagnosticSignInfo", text = "" },
	}

	for _, sign in ipairs(signs) do
		vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
	end

	local config = {
		-- disable virtual text
		virtual_text = false,
		-- show signs
		signs = {
			active = signs,
		},
		update_in_insert = true,
		underline = true,
		severity_sort = true,
		float = {
			focusable = false,
			style = "minimal",
			border = "rounded",
			source = "always",
			header = "",
			prefix = "",
		},
	}

	vim.diagnostic.config(config)

	vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
		border = "rounded",
	})

	vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
		border = "rounded",
	})
end

local function lsp_highlight_document(client, bufnr)
	-- Server capabilities spec:
	-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#serverCapabilities
	if client.server_capabilities.documentHighlightProvider then
		local augroup = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = true })
		vim.api.nvim_clear_autocmds({ buffer = bufnr, group = augroup })
		vim.api.nvim_create_autocmd("CursorHold", {
			callback = vim.lsp.buf.document_highlight,
			buffer = bufnr,
			group = augroup,
			desc = "Document Highlight",
		})
		vim.api.nvim_create_autocmd("CursorMoved", {
			callback = vim.lsp.buf.clear_references,
			buffer = bufnr,
			group = augroup,
			desc = "Clear All the References",
		})
	end
end

local function lsp_keymaps(client, bufnr)
	local opts = { noremap = true, silent = true }

	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end

	buf_set_keymap("n", "?", "<Cmd>Lspsaga peek_definition<CR>", opts)
	buf_set_keymap("n", "gd", "<Cmd>Lspsaga goto_definition<CR>", opts)
	buf_set_keymap("n", "gr", "<Cmd>Lspsaga lsp_finder<CR>", opts)
	buf_set_keymap("n", "K", "<Cmd>Lspsaga hover_doc<CR>", opts)
	-- buf_set_keymap("n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
	buf_set_keymap("n", "<C-k>", "<cmd>lua vim.lsp.buf.document_highlight()<CR>", opts)
	buf_set_keymap("n", "<F2>", "<cmd>Lspsaga rename<CR>", opts)
	-- buf_set_keymap("n", "<F2>", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
	buf_set_keymap("n", "ge", "<cmd>Lspsaga show_line_diagnostics<CR>", opts)

	if client.server_capabilities.documentFormattingProvider then
		local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
		vim.api.nvim_create_user_command("Format", "lua vim.lsp.buf.format()", {})
		vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = augroup,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end,
		})
	end
end

M.on_attach = function(client, bufnr)
	lsp_keymaps(client, bufnr)
	lsp_highlight_document(client, bufnr)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
-- folding
capabilities.textDocument.foldingRange = {
	dynamicRegistration = false,
	lineFoldingOnly = true,
}

local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if status_ok then
	capabilities = cmp_nvim_lsp.default_capabilities()
end

M.capabilities = capabilities

M.lsp_keymaps = lsp_keymaps
return M
