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
		vim.api.nvim_buf_set_option(bufnr, "formatexpr", "v:lua.require'conform'.formatexpr()")
		vim.api.nvim_create_user_command("Format", "lua require('conform').format({lsp_fallback = true})", {})
		-- local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
		-- vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
		-- vim.api.nvim_create_autocmd("BufWritePre", {
		-- 	group = augroup,
		-- 	buffer = bufnr,
		-- 	callback = function()
		-- 		vim.lsp.buf.format({ bufnr = bufnr })
		-- 	end,
		-- })
	end
end

-- codelens support

local autocmd_clear = vim.api.nvim_clear_autocmds
local augroup_codelens = vim.api.nvim_create_augroup("custom-lsp-codelens", { clear = true })
local autocmd = function(args)
	local event = args[1]
	local group = args[2]
	local callback = args[3]

	vim.api.nvim_create_autocmd(event, {
		group = group,
		buffer = args[4],
		callback = function()
			callback()
		end,
		once = args.once,
	})
end

-- line type hint
-- default: turn off
local virtlines_enabled = false

local refresh_virtlines = function()
	local params = { textDocument = vim.lsp.util.make_text_document_params() }
	vim.lsp.buf_request(0, "textDocument/codeLens", params, function(err, result, ctx, _)
		-- _G.dump(result)
		if err then
			return
		end

		if not result then
			return
		end

		local ns = vim.api.nvim_create_namespace("custom-lsp-codelens")
		vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)

		if not virtlines_enabled then
			return
		end

		for _, lens in ipairs(result) do
			local title = lens.command.title
			local range = lens.range
			local text = string.rep(" ", lens.range.start.character) .. title

			local line_num = range.start.line
			if line_num <= 0 then
				vim.api.nvim_buf_set_extmark(0, ns, 0, 0, {
					virt_text = { { text, "VirtualTextHint" } },
					virt_text_pos = "eol",
				})
			else
				-- _G.dump(line_num)
				vim.api.nvim_buf_set_extmark(0, ns, line_num, 0, {
					virt_lines = {
						{ { text, "VirtualTextHint" } },
					},
					virt_lines_above = true,
				})
			end
		end
	end)
end

M.toggle_virtlines = function(force)
	if force then
		virtlines_enabled = true
	else
		virtlines_enabled = not virtlines_enabled
	end
	refresh_virtlines()
end

local lsp_codelens = function()
	autocmd_clear({ group = augroup_codelens, buffer = 0 })
	autocmd({
		{
			-- "BufEnter",
			"BufWritePost",
			"CursorHold",
		},
		augroup_codelens,
		refresh_virtlines,
		0,
	})
end

M.on_attach = function(client, bufnr)
	lsp_keymaps(client, bufnr)
	lsp_highlight_document(client, bufnr)

	-- Display type information
	-- lsp_codelens()
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
M.lsp_codelens = lsp_codelens
return M
