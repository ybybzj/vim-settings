local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
	return
end

local search_replace_cmd =
	"<cmd>lua require('my.finder.utils').search_and_replace({select_word=true, cwd=require(\"my.helpers\").root_dir(vim.fn.expand('%:p:h'), vim.fn.getcwd()), continue_last_path = true})<cr>"
local search_replace_in_path_cmd =
	"<cmd>lua require('my.finder.utils').search_and_replace({select_word=true, cwd=require(\"my.helpers\").root_dir(vim.fn.expand('%:p:h'), vim.fn.getcwd())})<cr>"

local toggle_virtlines = "<cmd>lua require('my.lsp.handlers').toggle_virtlines()<cr>"

local setup = {
	preset = "helix",
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
			operators = true, -- adds help for operators like d, y, ... and registers them for motion / text object completion
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
	icons = {
		breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
		separator = "➜", -- symbol used between a key and it's label
		group = "+", -- symbol prepended to a group
	},
	win = {
		-- don't allow the popup to overlap with the cursor
		no_overlap = true,
		-- width = 1,
		-- height = { min = 4, max = 25 },
		-- col = 0,
		-- row = math.huge,
		-- border = "none",
		padding = { 1, 2 }, -- extra window padding [top/bottom, right/left]
		title = true,
		title_pos = "center",
		zindex = 1000,
		-- Additional vim.wo and vim.bo options
		bo = {},
		wo = {
			-- winblend = 10, -- value between 0-100 0 for fully opaque and 100 for fully transparent
		},
	},
	layout = {
		height = { min = 4 }, -- min and max height of the columns
		width = { min = 20 }, -- min and max width of the columns
		spacing = 3, -- spacing between columns
		align = "left", -- align columns left, center or right
	},
	show_help = true, -- show help message on the command line when the popup is visible
	triggers = {
		{ "<auto>", mode = "nxsot" },
	}, -- automatically setup triggers
	--- Mappings are sorted using configured sorters and natural sort of the keys
	--- Available sorters:
	--- * local: buffer-local mappings first
	--- * order: order of the items (Used by plugins like marks / registers)
	--- * group: groups last
	--- * alphanum: alpha-numerical first
	--- * mod: special modifier keys last
	--- * manual: the order the mappings were added
	--- * case: lower-case first
	sort = { "local", "order", "group", "alphanum", "mod" },
	show_keys = true, -- show the currently pressed key and its label as a message in the command line
	-- disable WhichKey for certain buf types and file types.
	disable = {
		ft = {},
		bt = {},
	},
	debug = false, -- enable wk.log in the current directory
}

local opts = {
	mode = "n", -- NORMAL mode
	prefix = "<space>",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = true, -- use `nowait` when creating keymaps
}

which_key.setup(setup)

which_key.add({
	{ "<space>o", "<cmd>AerialToggle<cr>", desc = "Toogle Lsp Outline" },
	{ "space>q", "<cmd>copen<cr>", desc = "Open quickfix list" },
	{ "<space>b", "<cmd>lua require('telescope.builtin').builtin()<cr>", desc = "Open telescope builtin picker list" },
})

-- session
which_key.add({
	{ "<space>s", group = "Session" },
	{ "<space>sr", "<cmd>lua MiniSessions.read()<cr>", desc = "Read Session" },
	{ "<space>ss", "<cmd>lua MiniSessions.select()<cr>", desc = "Select Session" },
	{ "<space>sw", "<cmd>lua MiniSessions.write('Session.vim')<cr>", desc = "Write Local Session" },
	{ "<space>sW", "<cmd>lua MiniSessions.write('GlobalSession.vim')<cr>", desc = "Write Global Session" },
})

-- git
which_key.add({
	{ "<space>g", group = "Git" },
	{ "<space>gs", group = "Git Status" },
	{ "<space>gso", "<cmd>DiffviewOpen<cr>", desc = "Open Git Status" },
	{ "<space>gsc", "<cmd>DiffviewClose<cr>", desc = "Close Git Status" },
	{ "<space>gsf", "<cmd>DiffviewFileHistory %<cr>", desc = "Open Current File History" },

	{ "<space>gg", "<cmd>lua _git_toggle()<CR>", desc = "GitUI" },
	{ "<space>gl", "<cmd>lua require 'gitsigns'.blame_line({full=true})<cr>", desc = "Blame" },

	{ "<space>gh", group = "Hunk" },
	{ "<space>ghj", "<cmd>lua require 'gitsigns'.next_hunk()<cr>", desc = "Next Hunk" },
	{ "<space>ghk", "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", desc = "Prev Hunk" },
	{ "<space>ghp", "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", desc = "Preview Hunk" },
	{ "<space>ghr", "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", desc = "Reset Hunk" },
	{ "<space>ghR", "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", desc = "Reset Buffer" },
	{ "<space>ghs", "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", desc = "Stage Hunk" },
	{ "<space>ghu", "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", desc = "Undo Stage Hunk" },

	{ "<space>go", "<cmd>lua require('my.finder.utils').git_status()<cr>", desc = "Open changed file" },
	{ "<space>gb", "<cmd>Telescope git_branches<cr>", desc = "Checkout branch" },

	{ "<space>gc", group = "Commit" },
	{ "<space>gcl", "<cmd>DiffviewFileHistory<cr>", desc = "Browse Commits" },
	{ "<space>gcc", "<cmd>Telescope git_commits<cr>", desc = "Checkout commit" },
	{ "<space>gcd", "<cmd>Telescope git_diffs diff_commits<cr>", desc = "Diff Commit" },
	{ "<space>gci", "<cmd>Telescope conventional_commits<cr>", desc = "Conventional Commit message" },
	{ "<space>gcf", "<cmd>lua require('my.finder.utils').git_bcommits()<cr>", desc = "Checkout commit for file" },

	{ "<space>gd", "<cmd>Gitsigns diffthis HEAD<cr>", desc = "Diff" },

	{ "<space>gm", group = "Merge conflict" },
	{ "<space>gmo", "<cmd>GitConflictChooseOurs<cr>", desc = "Select the current changes" },
	{ "<space>gmt", "<cmd>GitConflictChooseTheirs<cr>", desc = "Select the incoming changes" },
	{ "<space>gmb", "<cmd>GitConflictChooseBoth<cr>", desc = "Select both changes" },
	{ "<space>gmn", "<cmd>GitConflictChooseNone<cr>", desc = "Select both none of the changes" },
	{ "<space>gml", "<cmd>GitConflictNextConflict<cr>", desc = "Move to the next conflict." },
	{ "<space>gmh", "<cmd>GitConflictPrevConflict<cr>", desc = "Move to the previous conflict" },
	{ "<space>gmq", "<cmd>GitConflictListQf<cr>", desc = "Get all conflict to quickfix" },
})

-- finder
which_key.add({
	{ "<space>f", group = "Finder" },
	{ "<space>fo", "<cmd>lua require('telescope.builtin').oldfiles()<cr>", desc = "find recent files" },
	{ "<space>ff", "<cmd>lua require('telescope.builtin').find_files()<cr>", desc = "find files" },
	{ "<space>fb", "<cmd>lua require('telescope.builtin').buffers()<cr>", desc = "find buffers" },
	-- { "<space>fs", "<cmd>lua require('telescope.builtin').live_grep({case = 'smart'})<cr>", "live grep" },
	{ "<space>fs", "<Plug>CtrlSFCwordPath", desc = "Search and Replace" },
	{ "<space>fS", "<cmd>lua require('telescope.builtin').live_grep()<cr>", desc = "live grep with case sensitive" },
	{
		"<space>fw",
		"<cmd>lua require('my.finder.utils').grep_word({case = 'smart'})<cr>",
		desc = "find word in project",
	},
	{
		"<space>fW",
		"<cmd>lua require('my.finder.utils').grep_word()<cr>",
		desc = "find word in project with case sensitive",
	},

	{ "<space>fr", "<cmd>lua require('my.finder.utils').grep_last()<cr>", desc = "repeat last search" },
})

-- lsp
which_key.add({
	{ "<space>l", group = "LSP" },
	{ "<space>lr", "<cmd>lua require('telescope.builtin').lsp_references()<cr>", desc = "find references" },
	{
		"<space>lS",
		"<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>",
		desc = "find symbols in document",
	},
	{ "<space>ls", "<cmd>Telescope aerial<cr>", desc = "find symbols in document with filter" },
	{ "<space>la", "<cmd>Lspsaga code_action<cr>", desc = "list code actions" },
	{ "<space>ld", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "list diagnostics" },
	{ "<space>lf", "<cmd>lua vim.lsp.buf.format()<cr>", desc = "format document" },
	{ "<space>lo", "<cmd>Lspsaga outline<cr>", desc = "toggle outline" },
	{ "<space>lt", toggle_virtlines, desc = "toggle type hint" },
})

local map = require("my.shared").mapkey
map("", "<leader>cp", "<cmd>lua require(\"my.helpers\").cd_root(vim.fn.expand('%:p:h'), vim.fn.getcwd())<cr>")
map("", "<C-p>", "<cmd>lua require('telescope.builtin').oldfiles()<cr>")
map("", "<F8>", "<cmd>lua vim.diagnostic.goto_next({severity = {min = vim.diagnostic.severity.WARN}})<cr>")
map("", "<F7>", "<cmd>lua vim.diagnostic.goto_next()<cr>")
map("", "<leader>ff", search_replace_cmd)
map("", "<leader>fp", search_replace_in_path_cmd)
map("", "<M-r>", "<cmd>Lspsaga lsp_finder<cr>")
-- format --
map("n", "<F5>", "<cmd>lua require('conform').format({lsp_fallback=true})<cr>")
map("n", "<F4>", toggle_virtlines)
map("i", "<C-CR>", "<cmd>Copilot suggestion<cr>")
