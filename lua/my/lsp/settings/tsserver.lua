local handlers = require("my.lsp.handlers")

require("tsc").setup()

return {
	init_options = {
		preferences = {
			importModuleSpecifierPreference = "relative",
		},
	},

	on_attach = function(client, bufnr)
		client.server_capabilities.documentFormattingProvider = false
		local ts_utils = require("nvim-lsp-ts-utils")
		-- defaults
		ts_utils.setup({
			debug = false,
			disable_commands = false,
			enable_import_on_completion = true,
			import_all_timeout = 5000, -- ms

			--             -- eslint
			--             eslint_enable_code_actions = true,
			--             eslint_enable_disable_comments = true,
			--             eslint_bin = "eslint_d",
			--             eslint_config_fallback = nil,
			--             eslint_enable_diagnostics = true,
			--
			--             -- formatting
			--             enable_formatting = true,
			--             formatter = "prettier",
			--             formatter_config_fallback = nil,
			--
			--             -- parentheses completion
			--             complete_parens = false,
			--             signature_help_in_parens = false,
			--
			--             -- update imports on file move
			--             update_imports_on_move = false,
			--             require_confirmation_on_move = false,
			--             watch_dir = nil,
		})

		-- required to fix code action ranges
		ts_utils.setup_client(client)
		-- no default maps, so you may want to define some here
		vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>oi", ":TSLspOrganize<CR>", { silent = true })
		vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>fx", ":TSLspFixCurrent<CR>", { silent = true })
		vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>ai", ":TSLspImportAll<CR>", { silent = true })

		handlers.on_attach(client, bufnr)
	end,
}
