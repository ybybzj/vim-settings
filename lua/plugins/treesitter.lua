-- nvim-treesitter main branch (v1.x rewrite).
--
-- Migration from the frozen `master` branch (last commit 2025-05, locked for
-- Nvim 0.11) to `main` (actively maintained, requires Nvim 0.12+). The main
-- branch is an incompatible rewrite:
--   * does NOT support lazy-loading (lazy = false)
--   * parsers install to stdpath('data')/site, NOT into the plugin dir
--   * highlight/folds/indent are opt-in per filetype (not auto-enabled)
--   * custom parsers register via a `User TSUpdate` autocmd
--   * old configs.setup() monolith is gone; use setup{} + install{}
-- The 70-line directive patch (old master's set-lang-from-info-string! shims)
-- is deleted: main's markdown injections use native #set! predicates.
--
-- Folds are deliberately NOT configured here: nvim-ufo owns folds (it forces
-- foldmethod=manual and reads folds.scm through its own provider). Enabling
-- native vim.treesitter.foldexpr() would fight ufo.

local PARSERS = {
	"c",
	"lua",
	"rust",
	"zig",
	"javascript",
	"typescript",
	"go",
	"css",
	"html",
	"tsx",
	"toml",
	"yaml",
	"markdown",
	"markdown_inline",
	"latex",
	"moonbit",
	-- injection helper parsers (needed for lua/js/markdown injections)
	"comment",
	"query",
	"regex",
	"bash",
	"vim",
}

-- Filetypes that get treesitter-based indentation. indentexpr is experimental
-- on main, so gate it to known code languages only (not help/qf/terminal/etc).
local INDENT_FTS = {
	c = true,
	lua = true,
	rust = true,
	zig = true,
	javascript = true,
	typescript = true,
	javascriptreact = true,
	typescriptreact = true,
	go = true,
	css = true,
	html = true,
	tsx = true,
	toml = true,
	yaml = true,
	markdown = true,
	moonbit = true,
}

return {
	{
		"nvim-treesitter/nvim-treesitter",
		branch = "main", -- REQUIRED: default branch is the frozen master
		lazy = false, -- main does not support lazy-loading
		build = ":TSUpdate", -- updates already-installed parsers only
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
		},
		config = function()
			require("nvim-treesitter").setup {
				-- install_dir defaults to stdpath('data')/site — fine.
			}

			-- Custom moonbit parser (not in main's manifest).
			-- Registration MUST happen in a `User TSUpdate` autocmd: install{}
			-- fires reload_parsers() first (which executes this autocmd), then
			-- norm_languages() filters by parsers[lang] ~= nil. Registered here
			-- BEFORE install{...} below so moonbit is not skipped as unsupported.
			vim.api.nvim_create_autocmd("User", {
				pattern = "TSUpdate",
				callback = function()
					require("nvim-treesitter.parsers").moonbit = {
						install_info = {
							url = "https://github.com/moonbitlang/tree-sitter-moonbit",
							-- Pin to a known-good commit for reproducibility. The repo
							-- ships pre-generated src/parser.c, so no generate=true.
							revision = "5435c307c6cf2ef0d508a99047b06f35a4308444",
						},
					}
				end,
			})

			-- Highlighting + (gated) indentation per filetype.
			-- Folds are left to nvim-ufo (see header comment).
			vim.api.nvim_create_autocmd("FileType", {
				callback = function(ev)
					local ok = pcall(vim.treesitter.start)
					if not ok then
						return
					end
					if INDENT_FTS[vim.bo[ev.buf].filetype] then
						vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					end
				end,
			})

			-- First install: async (do NOT block startup with :wait()). The build
			-- step (:TSUpdate) only updates already-installed parsers, so the
			-- initial install must happen here. First open after a fresh install
			-- may lack highlights until the async install finishes.
			require("nvim-treesitter").install(PARSERS)
		end,
	},

	-- Textobjects: ported to main's keymap-based API.
	-- Current config keeps `select` DISABLED (only move is enabled) — preserved.
	{
		"nvim-treesitter/nvim-treesitter-textobjects",
		branch = "main",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		event = "BufReadPost",
		config = function()
			require("nvim-treesitter-textobjects").setup {
				move = { set_jumps = true },
			}

			local move = require("nvim-treesitter-textobjects.move")

			-- goto_next_start
			vim.keymap.set({ "n", "x", "o" }, "]B", function()
				move.goto_next_start("@block.outer", "textobjects")
			end, { desc = "Next block start" })
			vim.keymap.set({ "n", "x", "o" }, "]M", function()
				move.goto_next_start("@function.outer", "textobjects")
			end, { desc = "Next function start" })
			vim.keymap.set({ "n", "x", "o" }, "][", function()
				move.goto_next_start("@class.outer", "textobjects")
			end, { desc = "Next class start" })
			-- goto_next_end
			vim.keymap.set({ "n", "x", "o" }, "]b", function()
				move.goto_next_end("@block.outer", "textobjects")
			end, { desc = "Next block end" })
			vim.keymap.set({ "n", "x", "o" }, "]m", function()
				move.goto_next_end("@function.outer", "textobjects")
			end, { desc = "Next function end" })
			vim.keymap.set({ "n", "x", "o" }, "]]", function()
				move.goto_next_end("@class.outer", "textobjects")
			end, { desc = "Next class end" })
			vim.keymap.set({ "n", "x", "o" }, "]c", function()
				move.goto_next_end("@call.outer", "textobjects")
			end, { desc = "Next call end" })
			-- goto_previous_start
			vim.keymap.set({ "n", "x", "o" }, "[b", function()
				move.goto_previous_start("@block.inner", "textobjects")
			end, { desc = "Prev block start" })
			vim.keymap.set({ "n", "x", "o" }, "[m", function()
				move.goto_previous_start("@function.inner", "textobjects")
			end, { desc = "Prev function start" })
			vim.keymap.set({ "n", "x", "o" }, "[[", function()
				move.goto_previous_start("@class.inner", "textobjects")
			end, { desc = "Prev class start" })
			-- goto_previous_end
			vim.keymap.set({ "n", "x", "o" }, "[B", function()
				move.goto_previous_end("@block.outer", "textobjects")
			end, { desc = "Prev block end" })
			vim.keymap.set({ "n", "x", "o" }, "[M", function()
				move.goto_previous_end("@function.outer", "textobjects")
			end, { desc = "Prev function end" })
			vim.keymap.set({ "n", "x", "o" }, "[]", function()
				move.goto_previous_end("@class.outer", "textobjects")
			end, { desc = "Prev class end" })
			vim.keymap.set({ "n", "x", "o" }, "[c", function()
				move.goto_previous_end("@call.outer", "textobjects")
			end, { desc = "Prev call end" })
		end,
	},

	-- mini.ai: treesitter textobjects via queries (unchanged by the migration;
	-- verified against main's textobjects.scm query format).
	{
		"echasnovski/mini.ai",
		version = "*",
		opts = {},
		config = function()
			local mini_ai = require("mini.ai")
			local spec_treesitter = mini_ai.gen_spec.treesitter
			mini_ai.setup({
				custom_textobjects = {
					f = spec_treesitter({ a = "@function.outer", i = "@function.inner" }),
					c = spec_treesitter({
						a = { "@call.outer" },
						i = { "@call.inner" },
					}),
					a = spec_treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
				},
			})
		end,
	},
}
