require("conform").setup({
	formatters_by_ft = {
		lua = { "stylua" },
		-- Conform will run multiple formatters sequentially
		-- python = { "isort", "black" },
		-- Use a sub-list to run only the first available formatter
		javascript = { { "prettierd", "prettier" } },
		typescript = { { "prettierd", "prettier" } },
		zig = { "zigfmt" },
		ocaml = { "ocamlformat" },
		dune = { "dunefmt" },
		json = { "jq" },
	},
	format_on_save = {
		-- I recommend these options. See :help conform.format for details.
		lsp_fallback = true,
		timeout_ms = 500,
	},
	notify_on_error = true,
	formatters = {
		dunefmt = {
			-- This can be a string or a function that returns a string.
			-- When defining a new formatter, this is the only field that is required
			command = "dune",
			-- A list of strings, or a function that returns a list of strings
			-- Return a single string instead of a list to run the command in a shell
			args = { "format-dune-file", "$FILENAME" },

			-- Send file contents to stdin, read new contents from stdout (default true)
			-- When false, will create a temp file (will appear in "$FILENAME" args). The temp
			-- file is assumed to be modified in-place by the format command.
			stdin = true,
		},
	},
})
