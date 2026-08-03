# PLAN — nvim-treesitter `master` → `main` migration

## 0. Context & facts (researched 2026-08-03)

| Fact | Source |
|---|---|
| `master` frozen since 2025-05-24; README: locked for Nvim 0.11 compat | repo git log + README |
| `main` = "full, incompatible, rewrite: treat as a different plugin" | README (extracted live) |
| `main` requires Nvim 0.12+ and tree-sitter-cli >= 0.26.1 | README |
| Local env: Nvim 0.12.4, tree-sitter 0.26.11 (brew) | verified locally |
| `main` does NOT support lazy-loading | README |
| Highlight/folds/indent are NOT auto-enabled on `main` — opt-in per filetype | README |
| Custom languages: `User TSUpdate` autocmd + `require('nvim-treesitter.parsers').<lang> = {...}` | README "Adding custom languages" |
| markdown injections on `main` use native `#set!` predicates (no custom directives) | `runtime/queries/markdown/injections.scm` |
| textobjects moved to separate plugin, `main` branch, new setup API | nvim-treesitter-textobjects README |
| incremental-selection repo is 404 / gone — no successor | github 404 |
| nvim-treesitter-incremental-selection 404; matchup/autopairs integrations removed from main | repo inspection |

## 1. Current config surface (must be rewritten)

`lua/plugins/treesitter.lua` (209 lines):
- `build = ":TSUpdate"` — keep (works on main)
- moonbit via `get_parser_configs()` — replace with `User TSUpdate` autocmd
- `configs.setup({ ensure_installed, highlight, indent, incremental_selection, matchup, autopairs, textobjects })` — replace entirely
- 70-line directive patch (lines ~114-186) — DELETE
- mini.ai section uses `gen_spec.treesitter` — keep, verify queries resolve
- `nvim-treesitter-textobjects` dependency — switch branch to `main`, new setup

Dependencies on treesitter elsewhere:
- `lua/plugins/dev.lua` — mini.ai treesitter specs, ufo (uses treesitter provider + lsp fallback)
- `lua/plugins/markdown.lua` — render-markdown (comment mentions nvim-treesitter crash on 0.12 with archived master; verify fixed on main)
- `lua/plugins/blink.lua` — `vim.treesitter.get_node` (core API, unaffected)
- `lua/plugins/lsp.lua` — lspsaga depends on nvim-treesitter (optional dep)
- `lua/plugins/debug.lua` — check treesitter usage
- custom queries: `queries/moonbit/*.scm` (6 files) — must keep working

## 1b. External review (grok-4.5, high thinking — 2026-08-03)

Verdict: **APPROVE WITH CHANGES**. Required before execution:
1. **Do NOT set foldmethod/foldexpr in the FileType autocmd** — nvim-ufo owns folds
   (forces foldmethod=manual; its treesitter provider reads folds.scm itself).
   Enabling native TS folds fights ufo and breaks zR/zM.
2. **textobjects main API is keymap-based, not setup-based**: `setup` only takes
   select/move options; mappings are explicit `require("nvim-treesitter-textobjects.move").goto_next_end(...)` calls. Keep `select` DISABLED (current config only enables move).
3. **`:TSUpdate` is NOT a first-install**: it only updates already-installed parsers.
   After branch switch `stdpath('data')/site/parser` is empty → must call
   `require('nvim-treesitter').install{...}` explicitly. Avoid blocking `:wait()` on
   normal startup (async install; document that first open may lack highlights until install finishes).
4. **Fix verification commands**: use `:Inspect` (not :TSHighlightCapturesUnderCursor,
   a master-era command); use `require('nvim-treesitter').get_installed()`.
5. **moonbit query strategy**: vendored queries/moonbit/* are behind upstream (missing
   e.g. extenum_*). Decide refresh-from-upstream vs keep deliberate override + document.
   Gate indentexpr to known filetypes or installed parsers only; add injection helper
   parsers (comment, query, regex, bash, vim) to install list.

Other notes from review: `matchup = { enable = true }` is dead (no vim-matchup installed)
— safe to drop. Prefer textobjects as dependency of nvim-treesitter spec (not reverse).
Register moonbit BEFORE install{...} includes it. render-markdown `ignore` fn may be
relaxable after migration but don't assume — retest LSP hover floats. Clean stale master
lock after switch (`:Lazy sync`).

## 2. Target spec (new `lua/plugins/treesitter.lua` shape)

```lua
return {
  -- core (textobjects as dependency, not reverse)
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",           -- REQUIRED: default branch is master (frozen)
    lazy = false,              -- main does not support lazy-loading
    build = ":TSUpdate",       -- updates already-installed parsers only
    config = function()
      require("nvim-treesitter").setup {
        -- install_dir default (stdpath('data')/site) is fine
      }
      -- custom moonbit parser via User TSUpdate autocmd — MUST be registered
      -- BEFORE install{...} below so moonbit is not skipped as unsupported
      vim.api.nvim_create_autocmd("User", {
        pattern = "TSUpdate",
        callback = function()
          require("nvim-treesitter.parsers").moonbit = {
            install_info = {
              url = "https://github.com/moonbitlang/tree-sitter-moonbit",
              revision = "<sha>", -- pin to current HEAD for reproducibility
              -- no generate=true: repo ships pre-generated src/parser.c
              -- no queries=: keep vendored queries/moonbit override (see 1b #5)
            },
          }
        end,
      })
      -- enable highlight (+ gated indent) per filetype. FOLDS LEFT TO nvim-ufo.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          local ok = pcall(vim.treesitter.start)
          if not ok then return end
          -- gate indent to known filetypes (experimental on main)
          if vim.tbl_contains(PARSER_FTS, vim.bo[ev.buf].filetype) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
      -- first-install: async, do NOT block startup with :wait()
      require("nvim-treesitter").install(PARSERS)
    end,
  },
  -- textobjects (separate plugin, main branch)
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      -- setup takes select/move OPTIONS only (keep select DISABLED like current)
      require("nvim-treesitter-textobjects").setup { move = { set_jumps = true } }
      -- keymaps are explicit calls, e.g.:
      -- vim.keymap.set({ "n", "x", "o" }, "]M", function()
      --   require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
      -- end)
      -- ... port ALL existing move keymaps from current config 1:1
    end,
  },
  -- mini.ai (unchanged, verify)
}
```

### 2a. Parser install
`ensure_installed` is gone. `:TSUpdate` only updates installed parsers — first
install MUST use `require("nvim-treesitter").install { ... }` (or :TSInstall).
Decision: async `install { ... }` in config (no :wait() on startup — avoid 5-min
blocking regression); build step `:TSUpdate` covers subsequent updates. First open
after migration may lack highlights until async install completes — acceptable,
document it.

Include (add injection helper parsers flagged by review):
c lua rust zig javascript typescript go css html tsx toml yaml markdown
markdown_inline latex moonbit (via autocmd registration above)
+ comment query regex bash vim (injection helpers)

### 2b. moonbit parser details
Old: `files = { "src/parser.c", "src/scanner.c" }, branch = "main"`.
Main's install_info uses `revision` (commit sha), optional `generate = true` if no
pre-generated parser.c. moonbitlang/tree-sitter-moonbit has generated `src/parser.c`
(confirmed via repo file list). So `revision` optional → HEAD; may need
`queries = "queries"` to install the grammar's own queries (check what tree-sitter-moonbit
ships; current config vendored them into `queries/moonbit/`).

### 2c. FileType autocmd caveat
Blanket FileType autocmd enabling `vim.treesitter.start()` for ALL filetypes is the
lazy-but-broad approach. Alternative: enable per-language in ftplugin. Blanket is
acceptable and matches the README's global example; will verify no crashes on
filetypes without parsers (start() is a no-op / pcall'd).

## 3. Verification matrix (must pass before closure)

| Feature | Check |
|---|---|
| Highlight | open .lua/.rs/.ts/.go/.zig/.md/.mbt, confirm colors; `:Inspect` for captures |
| Folds | `zR`/`zM` via nvim-ufo (NOT native foldexpr — ufo owns folds) |
| Indent | type newline in nested blocks (lua/ts/go) |
| Textobjects | `]m`/`[m`/`]M` on functions; mini.ai `af`/`if`-style via mini.ai keymaps |
| Markdown injections | fenced code block → `:InspectTree` shows injection.content |
| moonbit | open .mbt file: parser loads, highlights active, textobjects work |
| render-markdown | `RenderMarkdown buf_toggle` on a .md file |
| blink markdown source | completion in markdown code fences |
| ts_context_commentstring | comment toggling in JSX/TSX |
| ufo folds | ufo provider fallback (lsp → treesitter → indent) still works |
| Startup | measure `--startuptime`, compare to ~118ms baseline |
| Parser state | `require('nvim-treesitter').get_installed()` — not vim.treesitter.get_parsers |
| moonbit queries | compare vendored queries/moonbit vs upstream tree-sitter-moonbit/queries (review flag: vendored may be behind) |

## 4. Risks & mitigations

1. Highlight/indent silently lost if autocmd wrong → mitigation: per-language
   verification matrix, `:checkhealth`.
2. All parsers must be reinstalled (install dir semantics change; parsers live in
   plugin dir on master, `stdpath('data')/site` on main) → mitigation: `build =
   ":TSUpdate"` + explicit install list; verify `vim.treesitter.get_parsers()`.
3. moonbit queries vendored in config may conflict with grammar queries →
   mitigation: check tree-sitter-moonbit `queries/` dir; prefer upstream or keep
   vendored override deliberately.
4. Blanket FileType autocmd may cause errors on non-parser filetypes → mitigation:
   pcall + `:checkhealth treesitter` + spot-check qf/help buffers.
5. textobjects keymap behavior changes (new API) → mitigation: port keymaps 1:1,
   verify each mapping.

## 5. Rollback
- git revert of the config commit restores master + patch.
- `lazy-lock.json` pins commits; `:Lazy restore` returns to pre-migration state.
- Parser reinstall is destructive only to installed .so; `:TSInstall` re-creates.
