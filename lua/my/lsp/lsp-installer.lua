local status_ok, lsp_installer = pcall(require, "nvim-lsp-installer")
if not status_ok then
	return
end

local handlers = require("my.lsp.handlers")

-- Register a handler that will be called for all installed servers.
-- Alternatively, you may also register handlers on specific server instances instead (see example below).
lsp_installer.on_server_ready(function(server)
	local opts = {
		on_attach = handlers.on_attach,
		capabilities = handlers.capabilities,
	}

	-- if server.name == "jsonls" then
	-- 	local jsonls_opts = require("my.lsp.settings.jsonls")
	-- 	opts = vim.tbl_deep_extend("force", jsonls_opts, opts)
	-- end

	if server.name == "sumneko_lua" then
		local sumneko_opts = require("my.lsp.settings.sumneko_lua")
		opts = vim.tbl_deep_extend("force", opts, sumneko_opts)
	end

	if server.name == "tsserver" then
		local ts_opts = require("my.lsp.settings.tsserver")
		opts = vim.tbl_deep_extend("force", opts, ts_opts)
	end
	if server.name == "zls" then
		opts.on_attach = function(client, bufnr)
			client.resolved_capabilities.document_formatting = false
			handlers.on_attach(client, bufnr)
		end
	end
	-- This setup() function is exactly the same as lspconfig's setup function.
	-- Refer to https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
	server:setup(opts)
end)
--
--- rust ---
-- curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
-- git  clone git@github.com:rust-analyzer/rust-analyzer.git
-- cargo xtask install --server
require("rust-tools").setup({
	autoSetHints = true,

	-- Whether to show hover actions inside the hover window
	-- This overrides the default hover handler
	hover_with_actions = true,

	runnables = {
		-- whether to use telescope for selection menu or not
		use_telescope = true,

		-- rest of the opts are forwarded to telescope
	},

	debuggables = {
		-- whether to use telescope for selection menu or not
		use_telescope = true,

		-- rest of the opts are forwarded to telescope
	},

	-- These apply to the default RustSetInlayHints command
	inlay_hints = {

		-- Only show inlay hints for the current line
		only_current_line = false,

		-- Event which triggers a refersh of the inlay hints.
		-- You can make this "CursorMoved" or "CursorMoved,CursorMovedI" but
		-- not that this may cause  higher CPU usage.
		-- This option is only respected when only_current_line and
		-- autoSetHints both are true.
		only_current_line_autocmd = "CursorHold",

		-- wheter to show parameter hints with the inlay hints or not
		show_parameter_hints = true,

		-- prefix for parameter hints
		parameter_hints_prefix = "<- ",

		-- prefix for all the other hints (type, chaining)
		other_hints_prefix = "=> ",

		-- whether to align to the length of the longest line in the file
		max_len_align = false,

		-- padding from the left if max_len_align is true
		max_len_align_padding = 1,

		-- whether to align to the extreme right or not
		right_align = false,

		-- padding from the right if right_align is true
		right_align_padding = 7,

		-- The color of the hints
		highlight = "Comment",
	},

	server = {
		on_attach = function(client, bufnr)
			client.resolved_capabilities.document_formatting = true
			handlers.on_attach(client, bufnr)
			local buf_set_keymap = function(...)
				vim.api.nvim_buf_set_keymap(bufnr, ...)
			end
			local opts = { noremap = true, silent = true }

			buf_set_keymap("n", "<space>[", "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>", opts)
			buf_set_keymap("n", "<space>]", "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>", opts)
			buf_set_keymap("n", "<space>rr", "<cmd>RustRun<CR>", opts)
			buf_set_keymap("n", "<space>ra", "<cmd>RustRunnables<CR>", opts)
		end,
	},
})
