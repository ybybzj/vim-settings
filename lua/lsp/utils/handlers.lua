local utils = require("utils")
local M = {}
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

local function lsp_keymaps(_, bufnr, keymaps)
	local opts = { noremap = true, silent = true }

	local function buf_set_keymap(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end

	for shortcut, k_opts in pairs(keymaps) do
		buf_set_keymap("n", shortcut, k_opts.cmd, utils.extends(opts, opts.opts))
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

local lsp_codelens = function(_, _)
	autocmd_clear({ group = augroup_codelens, buffer = 0 })
	autocmd({
		{
			-- "BufEnter",
			"TextChanged",
			"InsertLeave",
			"LspAttach",
			-- "BufWritePost",
			"CursorHold",
		},
		augroup_codelens,
		refresh_virtlines,
		0,
	})
end

M.make_client_capabilities = function()
	local capabilities = vim.lsp.protocol.make_client_capabilities()
	-- folding
	capabilities.textDocument.foldingRange = {
		dynamicRegistration = false,
		lineFoldingOnly = true,
	}

	local status_ok, blink_nvim_lsp = pcall(require, "blink.cmp")
	if status_ok then
		capabilities = blink_nvim_lsp.get_lsp_capabilities(capabilities)
	end
	return capabilities
end

M.lsp_highlight_document = lsp_highlight_document
M.lsp_keymaps = lsp_keymaps
M.lsp_codelens = lsp_codelens

return M
