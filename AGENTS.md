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

### Treesitter setup
- nvim-treesitter runs on the `main` branch (v1.x rewrite), not frozen master.
- Maintenance/API notes live in `docs/treesitter-main-migration.md` — read that
  before editing `lua/plugins/treesitter.lua` or `queries/moonbit/`.

