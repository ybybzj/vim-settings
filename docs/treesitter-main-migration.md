# nvim-treesitter (main branch) — maintenance notes

The config uses the nvim-treesitter **`main`** branch (v1.x rewrite), NOT the
frozen `master` branch. This document captures the durable facts to preserve
when editing the config. Migration performed 2026-08-03 (commits `6d2abf0`,
`7309b2d`).

## Branch & loading

- `branch = "main"` is required in the plugin spec — the repo's default branch
  is the frozen `master` (locked for Nvim 0.11 compat).
- `lazy = false` is mandatory: main does not support lazy-loading.

## API (differs from master)

- `require('nvim-treesitter').setup{}` — only `install_dir` option (defaults to
  `stdpath('data')/site`, fine).
- `require('nvim-treesitter').install{...}` — async first-install. There is NO
  `nvim-treesitter.configs` module on main.
- `build = ":TSUpdate"` only updates **already-installed** parsers. First
  install after a branch switch / fresh clone must go through `install{...}`
  (parsers live in `stdpath('data')/site/parser`, not the plugin dir).

## Features

- Highlighting is opt-in per filetype: `FileType` autocmd calling
  `vim.treesitter.start()`.
- Folds are deliberately left to **nvim-ufo** (it forces `foldmethod=manual`
  and has a `make-range!` compat shim for the nvim-treesitter v1.0+ API).
  Do NOT add native `foldexpr`/`foldmethod=expr` — it fights ufo.
- Indent is gated to known code filetypes via `indentexpr` (experimental on
  main); see `INDENT_FTS` in `lua/plugins/treesitter.lua`.

## moonbit parser

- Owned by **moonbit-community/moonbit.nvim** (see `lua/plugins/moonbit.lua`):
  it registers moonbitlang/tree-sitter-moonbit via its own `User TSUpdate`
  autocmd and auto-installs it (`treesitter.auto_install`). Do NOT re-add the
  old custom registration here — the plugin is the single owner.
- Vendored queries in `queries/moonbit/` are synced from upstream
  moonbitlang/tree-sitter-moonbit (with a provenance header) and take runtime
  precedence over the plugin's own queries. Refresh from upstream rather than
  hand-editing.

## Markdown

- Markdown injections use native `#set!` predicates on main. Do NOT
  reintroduce the old `set-lang-from-info-string!` / `downcase!` directive
  shims (the 70-line patch was removed in the main-branch migration).

## textobjects

- `nvim-treesitter-textobjects` is a separate plugin on `main` with a
  keymap-based API (`require("nvim-treesitter-textobjects.move").goto_*`),
  configured in `lua/plugins/treesitter.lua`. Select textobjects are DISABLED
  (move-only) by design.
- It is a dependency of the nvim-treesitter spec (not the reverse direction).

## Removed in migration

- `incremental_selection` from the old master config has NO successor (repo
  gone) — do not re-add it.
- `matchup = { enable = true }` was dead config (no vim-matchup installed) —
  dropped.

## Requirements

- `tree-sitter-cli` via brew (the `tree-sitter-cli` formula, NOT the
  `tree-sitter` library formula — a common install mistake).
- Nvim 0.12+ (main's support policy: latest stable + latest nightly).
