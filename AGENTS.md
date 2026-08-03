# AGENTS.md - Neovim Configuration

## Overview
Personal Neovim config using lazy.nvim plugin manager with LSP, treesitter, and modern tooling.

## Build/Test Commands
- No traditional build/test - this is a Neovim config
- Reload config: `:source %` or restart Neovim
- Check plugin status: `:Lazy`
- Check LSP status: `:LspInfo`

## Code Style Guidelines

### File Structure
- All Lua modules return tables: `local M = {}; return M` or plugin spec tables
- Use `snake_case.lua` for filenames (e.g., `find_and_replace.lua`)
- Use trailing underscore for reserved words: `lua_.lua`

### Imports/Requires
- Use `require("config.module")` for relative imports
- Wrap external requires with pcall: `local ok, mod = pcall(require, "module")`

### Naming Conventions
- Module table: `M` (uppercase)
- Local vars/functions: `snake_case` or `camelCase`
- Vim API aliases at top: `local opt = vim.opt; local map = vim.keymap.set`

### LSP Config Pattern (lua/lsp/*.lua)
Each file exports: `{ server_name, opts, formatter, linter, lspconfig, keys }`

### Globals (defined in .luarc.json)
`vim`, `Snacks`, `_toggle_lazygit`

### AI Assistant Capabilities(supermaven + Sidekick + Opencode-Cli)

## nvim-treesitter (main branch) — maintenance notes

The config uses the nvim-treesitter **`main`** branch (v1.x rewrite), NOT the
frozen `master` branch. Key facts to preserve when editing:

- `branch = "main"` is required — the repo's default branch is the frozen
  `master` (locked for Nvim 0.11 compat). `lazy = false` is mandatory: main
  does not support lazy-loading.
- API is completely different from master: `require('nvim-treesitter').setup{}`
  (only `install_dir` option) + async `require('nvim-treesitter').install{...}`.
  There is NO `nvim-treesitter.configs` module on main.
- `build = ":TSUpdate"` only updates **already-installed** parsers. First
  install after a branch switch / fresh clone must go through `install{...}`
  (parsers live in `stdpath('data')/site/parser`, not the plugin dir).
- Highlighting is opt-in per filetype via a `FileType` autocmd calling
  `vim.treesitter.start()`. Folds are deliberately left to **nvim-ufo** (it
  forces `foldmethod=manual` and has a `make-range!` compat shim for the
  nvim-treesitter v1.0+ API). Indent is gated to known code filetypes.
- The moonbit parser is custom-registered via a `User TSUpdate` autocmd
  (see `lua/plugins/treesitter.lua`), pinned to a specific tree-sitter-moonbit
  revision. It must be registered BEFORE `install{...}` runs. Vendored queries
  in `queries/moonbit/` are synced from upstream tree-sitter-moonbit.
- Markdown injections use native `#set!` predicates on main — do NOT reintroduce
  the old `set-lang-from-info-string!` / `downcase!` directive shims (the 70-line
  patch was removed in the main-branch migration, 2026-08).
- `nvim-treesitter-textobjects` is a separate plugin on `main` with a
  keymap-based API (`require("nvim-treesitter-textobjects.move").goto_*`),
  configured in `lua/plugins/treesitter.lua`. Select textobjects are DISABLED
  (move-only) by design.
- `incremental_selection` from the old master config has NO successor (repo
  gone) — do not re-add it.
- Requires `tree-sitter-cli` (brew: `tree-sitter-cli`, NOT the `tree-sitter`
  library formula) and Nvim 0.12+.

