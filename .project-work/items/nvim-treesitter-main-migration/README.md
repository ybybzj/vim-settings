# nvim-treesitter: migrate from archived `master` to `main`

## Status
- state: in_progress
- focus: Phases 1-3 executed; runtime GUI verification + commit + closure pending

## Why
- nvim-treesitter `master` is frozen (last commit 2025-05-24); official README says
  master is locked "for backward compatibility with Nvim 0.11" — this config runs
  Nvim 0.12.4, outside the stated compat window.
- Current config carries a 70-line hand-rolled patch (lua/plugins/treesitter.lua)
  shimming old directive handlers (`set-lang-from-info-string!`, `downcase!`) to
  keep markdown injections working on 0.12. This is fragile and unmaintained.
- `main` is the actively maintained rewrite (last commit 2026-08-01), requires
  Nvim 0.12+ and tree-sitter-cli >= 0.26.1 — both already satisfied locally.

## User goals
- Remove the archived-branch fragility permanently (audit issue #2).
- Preserve: highlighting, folds, indentation, textobjects, moonbit parser,
  markdown rendering/injections, mini.ai treesitter textobjects.

## Locked decisions
- Migrate to `main` branch (confirmed by user 2026-08-03).
- `incremental_selection` will be dropped — separate repo is gone (404), no
  replacement exists. (User confirmation requested; default = drop.)
- moonlight parser: register via documented `User TSUpdate` autocmd mechanism.

## Open questions
- Drop incremental_selection keymaps outright, or keep any partial alternative?
- Confirm highlight/indent enable strategy: FileType autocmd in config vs ftplugin.

## Deferred / out of scope
- Deeper bespoke-code trimming (workspace/, neotree.lua, hunk-diff modules) —
  separate effort, audit issue #3.

## Execution checklist
- [x] Phase 1: switch nvim-treesitter to `main`, rewrite treesitter.lua config
  - [x] `lazy = false`, remove `configs.setup()` monolith
  - [x] new API: `require('nvim-treesitter').setup {}` + async `install {}` (no :wait blocking)
  - [x] enable highlight per filetype (FileType autocmd); folds LEFT TO nvim-ufo (review fix)
  - [x] gate indentexpr to known filetypes (experimental on main; review fix)
  - [x] port moonbit parser registration to `User TSUpdate` autocmd, registered BEFORE install
  - [x] delete the 70-line markdown directive patch (verified deletable by review)
  - [x] update parser install list + injection helpers (comment/query/regex/bash/vim)
- [x] Phase 2: switch nvim-treesitter-textobjects to `main`
  - [x] new keymap-based API (setup takes options only; explicit .move/.select calls)
  - [x] preserve existing move keymaps ([m, ]m, etc.); keep select DISABLED (review fix)
  - [x] textobjects as dependency of nvim-treesitter spec, not reverse (review fix)
  - [x] verify mini.ai treesitter specs still resolve
- [x] Phase 3: reinstall all parsers and verify per-language
  - [x] `install {}` FIRST (TSUpdate alone is no-op on empty install dir — review fix), then `:TSUpdate`
  - [x] verify highlighting, folds (via ufo), indent on c/lua/rust/ts/go/markdown/zig/moonbit
  - [x] verify markdown injections (fenced code blocks)
  - [x] verify render-markdown, blink markdown source, ts_context_commentstring
  - [x] decide moonbit query strategy: refresh vendored from upstream vs keep override + document (review flag)
- [ ] Phase 4: health + startup verification
  - [x] `:checkhealth nvim-treesitter` clean (no errors; 21 parsers + queries OK)
  - [x] startup time regression check (120ms vs 118ms baseline — no regression)
  - [ ] commit config changes; update lazy-lock.json; clean stale master lock
- [ ] Closure: distill durable notes into AGENTS.md / README, clean work item
- [ ] Review note: `matchup = { enable = true }` is dead config (no vim-matchup) — safe to drop

## Current artifacts
- `PLAN.md` — detailed migration plan with per-file changes and verification steps
