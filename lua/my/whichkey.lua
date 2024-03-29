local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
	return
end

local live_search_replace_cmd =
	"<cmd>lua require('my.finder.utils').search_and_replace({select_word=true, cwd=require(\"my.helpers\").root_dir(vim.fn.expand('%:p:h'), vim.fn.getcwd())})<cr>"

local toggle_virtlines = "<cmd>lua require('my.lsp.handlers').toggle_virtlines()<cr>"

local setup = {
	plugins = {
		marks = true, -- shows a list of your marks on ' and `
		registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
		spelling = {
			enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
			suggestions = 20, -- how many suggestions should be shown in the list?
		},
		-- the presets plugin, adds help for a bunch of default keybindings in Neovim
		-- No actual key bindings are created
		presets = {
			operators = false, -- adds help for operators like d, y, ... and registers them for motion / text object completion
			motions = true, -- adds help for motions
			text_objects = true, -- help for text objects triggered after entering an operator
			windows = true, -- default bindings on <c-w>
			nav = true, -- misc bindings to work with windows
			z = true, -- bindings for folds, spelling and others prefixed with z
			g = true, -- bindings for prefixed with g
		},
	},
	-- add operators that will trigger motion and text object completion
	-- to enable all native operators, set the preset / operators plugin above
	-- operators = { gc = "Comments" },
	key_labels = {
		-- override the label used to display some keys. It doesn't effect WK in any other way.
		-- For example:
		-- ["<space>"] = "SPC",
		-- ["<cr>"] = "RET",
		-- ["<tab>"] = "TAB",
	},
	icons = {
		breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
		separator = "➜", -- symbol used between a key and it's label
		group = "+", -- symbol prepended to a group
	},
	popup_mappings = {
		scroll_down = "<c-d>", -- binding to scroll down inside the popup
		scroll_up = "<c-u>", -- binding to scroll up inside the popup
	},
	window = {
		border = "rounded", -- none, single, double, shadow
		position = "bottom", -- bottom, top
		margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
		padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
		winblend = 0,
	},
	layout = {
		height = { min = 4, max = 25 }, -- min and max height of the columns
		width = { min = 20, max = 50 }, -- min and max width of the columns
		spacing = 3, -- spacing between columns
		align = "left", -- align columns left, center or right
	},
	ignore_missing = true, -- enable this to hide mappings for which you didn't specify a label
	hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
	show_help = true, -- show help message on the command line when the popup is visible
	triggers = "auto", -- automatically setup triggers
	-- triggers = {"<leader>"} -- or specify a list manually
	triggers_blacklist = {
		-- list of mode / prefixes that should never be hooked by WhichKey
		-- this is mostly relevant for key maps that start with a native binding
		-- most people should not need to change this
		i = { "j", "k" },
		v = { "j", "k" },
	},
}

local opts = {
	mode = "n", -- NORMAL mode
	prefix = "<space>",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = true, -- use `nowait` when creating keymaps
}

local mappings = {
	-- convinient shortcuts
	o = { "<cmd>AerialToggle<cr>", "Toogle Lsp Outline" },
	q = { "<cmd>copen<cr>", "Open quickfix list" },
	b = { "<cmd>lua require('telescope.builtin').builtin()<cr>", "Open telescope builtin picker list" },
	-- session
	s = {
		name = "Session",
		r = { "<cmd>lua MiniSessions.read()<cr>", "Read Session" },
		s = { "<cmd>lua MiniSessions.select()<cr>", "Select Session" },
		w = { "<cmd>lua MiniSessions.write('Session.vim')<cr>", "Write Local Session" },
		W = { "<cmd>lua MiniSessions.write('GlobalSession.vim')<cr>", "Write Global Session" },
	},
	-- git
	g = {
		name = "Git",
		s = {
			name = "Git Status",
			o = { "<cmd>DiffviewOpen<cr>", "Open Git Status" },
			c = { "<cmd>DiffviewClose<cr>", "Close Git Status" },
			f = { "<cmd>DiffviewFileHistory %<cr>", "Open Current File History" },
		},
		g = { "<cmd>lua _git_toggle()<CR>", "GitUI" },
		l = { "<cmd>lua require 'gitsigns'.blame_line({full=true})<cr>", "Blame" },
		h = {
			name = "Hunk",
			j = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", "Next Hunk" },
			k = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", "Prev Hunk" },
			p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
			r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
			R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
			s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
			u = {
				"<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
				"Undo Stage Hunk",
			},
		},

		o = { "<cmd>lua require('my.finder.utils').git_status()<cr>", "Open changed file" },
		b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
		c = {
			Name = "Commit",
			l = { "<cmd>DiffviewFileHistory<cr>", "Browse Commits" },
			c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
			d = { "<cmd>Telescope git_diffs diff_commits<cr>", "Diff Commit" },
			i = { "<cmd>Telescope conventional_commits<cr>", "Conventional Commit message" },
		},
		f = { "<cmd>lua require('my.finder.utils').git_bcommits()<cr>", "Checkout commit for file" },
		d = {
			"<cmd>Gitsigns diffthis HEAD<cr>",
			"Diff",
		},
		m = {
			name = "Merge conflict",
			o = {
				"<cmd>GitConflictChooseOurs<cr>",
				"Select the current changes",
			},
			t = {
				"<cmd>GitConflictChooseTheirs<cr>",
				"Select the incoming changes",
			},
			b = {
				"<cmd>GitConflictChooseBoth<cr>",
				"Select both changes",
			},
			n = {
				"<cmd>GitConflictChooseNone<cr>",
				"Select both none of the changes",
			},
			l = {
				"<cmd>GitConflictNextConflict<cr>",
				"Move to the next conflict.",
			},
			h = {
				"<cmd>GitConflictPrevConflict<cr>",
				"Move to the previous conflict",
			},
			q = {
				"<cmd>GitConflictListQf<cr>",
				"Get all conflict to quickfix",
			},
		},
	},
	-- finder
	f = {
		name = "Finder",
		o = { "<cmd>lua require('telescope.builtin').oldfiles()<cr>", "find recent files" },
		f = { "<cmd>lua require('telescope.builtin').find_files()<cr>", "find files" },
		b = { "<cmd>lua require('telescope.builtin').buffers()<cr>", "find buffers" },
		-- s = { "<cmd>lua require('telescope.builtin').live_grep({case = 'smart'})<cr>", "live grep" },
		s = { live_search_replace_cmd, "Search and Replace" },
		S = { "<cmd>lua require('telescope.builtin').live_grep()<cr>", "live grep with case sensitive" },
		w = {
			"<cmd>lua require('my.finder.utils').grep_word({case = 'smart'})<cr>",
			"find word in project",
		},
		W = {
			"<cmd>lua require('my.finder.utils').grep_word()<cr>",
			"find word in project with case sensitive",
		},

		r = {
			"<cmd>lua require('my.finder.utils').grep_last()<cr>",
			"repeat last search",
		},
	},

	-- lsp
	l = {
		name = "LSP",
		r = { "<cmd>lua require('telescope.builtin').lsp_references()<cr>", "find references" },
		S = { "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", "find symbols in document" },
		s = { "<cmd>Telescope aerial<cr>", "find symbols in document with filter" },
		a = { "<cmd>Lspsaga code_action<cr>", "list code actions" },
		d = { "<cmd>TroubleToggle document_diagnostics<cr>", "list diagnostics" },
		f = { "<cmd>lua vim.lsp.buf.format()<cr>", "format document" },
		o = { "<cmd>Lspsaga outline<cr>", "toggle outline" },
		t = { toggle_virtlines, "toggle type hint" },
	},
}

which_key.setup(setup)
which_key.register(mappings, opts)
local map = require("my.shared").mapkey
map("", "<leader>cp", "<cmd>lua require(\"my.helpers\").cd_root(vim.fn.expand('%:p:h'), vim.fn.getcwd())<cr>")
map("", "<C-p>", "<cmd>lua require('telescope.builtin').oldfiles()<cr>")
map("", "<F8>", "<cmd>lua vim.diagnostic.goto_next({severity = {min = vim.diagnostic.severity.WARN}})<cr>")
map("", "<F7>", "<cmd>lua vim.diagnostic.goto_next()<cr>")
map("", "<leader>f", live_search_replace_cmd)
map("", "<M-r>", "<cmd>Lspsaga lsp_finder<cr>")
-- format --
map("n", "<F5>", "<cmd>lua require('conform').format({lsp_fallback=true})<cr>")
map("n", "<F4>", toggle_virtlines)
