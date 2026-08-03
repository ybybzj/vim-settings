-- Official community MoonBit plugin (moonbit-community/moonbit.nvim).
--
-- Replaces the hand-rolled MoonBit editor integration (previously in
-- lua/lsp/moonbit.lua, which is now formatter-only): it owns filetype
-- detection (.mbt/.mbti + moon.mod/moon.pkg/moon.work), the native OCaml
-- LSP (~/.moon/bin/moon-lsp --stdio), treesitter parser install/update,
-- mooncakes completion (blink.cmp), jsonls schemas for moon.mod.json /
-- moon.pkg.json, and editor/compiler helpers.
--
-- lazy.nvim calls require("moonbit").setup(opts) automatically via `opts`.

return {
	{
		"moonbit-community/moonbit.nvim",
		-- `ft` (not bare `event`) is required: lazy.nvim only sources a
		-- lazy-loaded plugin's ftdetect/ scripts when `ft` is set, which is
		-- what registers the .mbt/.mbti + moon.mod/moon.pkg/moon.work →
		-- moonbit filetype mappings before the plugin loads. The extra
		-- BufReadPre events also load it for moon.mod.json / moon.pkg.json
		-- (jsonls schemas) and *.mbt.md doc buffers.
		ft = { "moonbit" },
		event = {
			"BufReadPre */moon.mod*",
			"BufReadPre */moon.pkg*",
			"BufReadPre */moon.work*",
			"BufReadPre *.mbt.md",
		},
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {
			-- Parser install/update is owned by the plugin (registers
			-- moonbitlang/tree-sitter-moonbit on `User TSUpdate`). Highlight/
			-- indent/fold queries stay vendored locally in queries/moonbit/
			-- (config runtime dir takes precedence over the plugin's).
			treesitter = { enabled = true, auto_install = true },
			-- Native OCaml LSP is the default; set lsp = { native = false }
			-- to fall back to the legacy TS moonbit-lsp.
			lsp = { native = true },
			mooncakes = { virtual_text = true, use_local = true },
			-- Registers moon.mod.json / moon.pkg.json schemas with jsonls
			-- (merged into the existing json.lua settings).
			jsonls = {},
		},
	},
}
