# TypeScript LSP: native TS 7 (tsgo) with vtsls fallback

Status: active since 2026-09-10. Applies to `lua/lsp/typescript.lua` and
`lua/lsp/utils/tsgo.lua`.

## Why

The old setup used vtsls + its bundled JS `tsserver` (TS 5.9.3, two processes per
workspace root, each `--max-old-space-size=3072`). On this monorepo that produced
a permanent crash loop:

- `~/.local/state/nvim/lsp.log`: `TSServer exited. Code: null. Signal: SIGABRT`
  every ~15 s (185 events in one hour).
- `~/Library/Logs/DiagnosticReports/node-*.ips`: 64 V8 heap aborts
  (`Allocation failed - JavaScript heap out of memory`).

Root cause, measured by driving a real tsserver directly:

| buffer set | projects (files) | load peak RSS | vs 3072 MB cap |
| --- | --- | --- | --- |
| 4 files, one tsconfig scope | 1 (6,568) | 2.5 GB | survives |
| 4 files, 4 tsconfig scopes | 4 (29,827) | 7.2 GB | **SIGABRT** |

tsserver loads one Program per *distinct nearest tsconfig* and keeps it while any
of its files is open. The peak is a transient load spike (it GCs back to ~50 MB
afterwards), but the spike exceeded the cap, so the server died *during* load,
restarted, and died again — forever.

`tsgo` (TypeScript 7, native Go) has no V8 heap cap and is far lighter/faster:
one 13k-file project loads in ~1.9 s at ~1.9 GB steady, versus tsserver's
multi-GB transient spike.

## How it is wired

`lua/lsp/typescript.lua` sets `USE_TSGO = true` and registers a `tsc` client
(named `tsgo` until nvim-lspconfig deprecated that name; lspconfig's
`lsp/tsc.lua` turns on per-function code lenses, which the config switches off)
(`--lsp -stdio`) alongside the existing `vtsls` config. Both backends decide
per buffer through `root_dir(bufnr, on_dir)`, which Neovim treats as an
activation gate:

```
tsgo   : on_dir(root) when the workspace ships native TS 7
vtsls  : on_dir(root) when it does not   (TS 5.x repos keep working unchanged)
```

So exactly one server runs per workspace, and repos without
`@typescript/native` silently keep the previous vtsls behaviour.

- `root_dir` prefers the **git worktree root**, so a single server serves every
  package — required for working from the repo root with buffers in many
  packages. Project discovery per file is done by tsgo itself.
- `lua/lsp/utils/tsgo.lua` resolves the binary by walking up from the workspace
  root: `node_modules/@typescript/native/lib/tsc.js` (or
  `node_modules/typescript/lib/tsc.js` when it is a TS 7 package — detected via
  the sibling `lib/getExePath.js`, which TS 5/6 packages lack), then the pnpm
  platform package glob, then `tsgo` on `PATH`. Results are cached per root.
- The `tsc.js` shim `execve()`s the native platform binary, so no wrapper node
  process is left behind.

## Reverting

Two equivalent ways:

1. Flip the switch: set `USE_TSGO = false` in `lua/lsp/typescript.lua`. That
   restores vtsls-only behaviour immediately (the tsgo code stays dormant).
2. Full revert of the change set:

   ```bash
   cd ~/.config/nvim
   git checkout -- lua/lsp/typescript.lua
   rm lua/lsp/utils/tsgo.lua docs/typescript-lsp-tsgo.md
   ```

   A copy of the pre-change file is kept at
   `~/nvim-config-backup-tsgo-<timestamp>/typescript.lua`. Restart Neovim
   afterwards (plugin config is evaluated at startup).

## Known gaps versus vtsls

- `:VtsExec` helpers (`organize_imports`, `rename_file`, `select_ts_version`,
  `file_references`) need a vtsls client. Their mappings are routed through
  `tsgo.vts_exec()` which warns instead of erroring when tsgo owns the
  workspace. `organize_imports` is still available as a code action
  (`<space>la`).
- tsgo is alpha software; when a feature misbehaves, check whether vtsls
  (revert option 1) has it.
- Neovim logs one harmless warning per tsgo start:
  `triggers a registerCapability handler for workspace/didChangeConfiguration
  despite dynamicRegistration set to false ... this warning is harmless`.

## Verifying

```bash
# which server is attached, and its root (should be tsc + the worktree root)
nvim --headless -u ~/.config/nvim/init.lua \
  -c 'edit packages/excel/front/sdk/plugins/emptySheetTip/index.tsx' \
  -c 'sleep 8' -c 'lua =vim.lsp.get_clients()' -c 'qa!'

# the crash loop must stay silent
tail -f ~/.local/state/nvim/lsp.log | grep 'TSServer exited'

# one native process, ~2 GB, no node wrapper
ps -eo pid,ppid,rss,command | grep 'lib/tsc --lsp'
```
