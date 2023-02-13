local null_ls_status_ok, null_ls = pcall(require, "null-ls")
if not null_ls_status_ok then
	return
end

-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/formatting
local formatting = null_ls.builtins.formatting
-- https://github.com/jose-elias-alvarez/null-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics
local diagnostics = null_ls.builtins.diagnostics

null_ls.setup({
	debug = false,
	sources = {
		formatting.prettierd,
		formatting.stylua,
		formatting.zigfmt,
		diagnostics.eslint_d,
	},
	on_attach = function(client, bufnr)
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
	end,
})
