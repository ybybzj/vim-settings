-- hopper setting --
require("hop").setup()

-- diagnostic tool
require("trouble").setup({
	-- your configuration comes here
	-- or leave it empty to use the default settings
	-- refer to the configuration section below
})

-- autopairs
local status_ok, npairs = pcall(require, "nvim-autopairs")

if status_ok then
	npairs.setup()

	local Rule = require("nvim-autopairs.rule")
	npairs.add_rule(Rule("|", "|", "zig"))
end

-- aerial
require("aerial").setup({
	-- Priority list of preferred backends for aerial.
	-- This can be a filetype map (see :help aerial-filetype-map)
	backends = {
		_ = { "lsp", "treesitter", "markdown" },
		lua = { "treesitter" },
	},
	layout = {
		-- These control the width of the aerial window.
		-- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
		-- min_width and max_width can be a list of mixed types.
		-- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
		max_width = { 40, 0.2 },
		width = nil,
		min_width = 10,

		-- Enum: prefer_right, prefer_left, right, left, float
		-- Determines the default direction to open the aerial window. The 'prefer'
		-- options will open the window in the other direction *if* there is a
		-- different buffer in the way of the preferred direction
		default_direction = "prefer_right",

		-- Set to true to only open aerial at the far right/left of the editor
		-- Default behavior opens aerial relative to current window
		placement_editor_edge = false,
	},

	-- Enum: persist, close, auto, global
	--   persist - aerial window will stay open until closed
	--   close   - aerial window will close when original file is no longer visible
	--   auto    - aerial window will stay open as long as there is a visible
	--             buffer to attach to
	--   global  - same as 'persist', and will always show symbols for the current buffer
	close_automatic_events = { "unsupported" },

	-- Keymaps in aerial window. Can be any value that `vim.keymap.set` accepts OR a table of keymap
	-- options with a `callback` (e.g. { callback = function() ... end, desc = "", nowait = true })
	-- Additionally, if it is a string that matches "actions.<name>",
	-- it will use the mapping at require("aerial.actions").<name>
	-- Set to `false` to remove a keymap
	keymaps = {
		["?"] = "actions.show_help",
		["g?"] = "actions.show_help",
		["<CR>"] = "actions.jump",
		["<2-LeftMouse>"] = "actions.jump",
		["<C-v>"] = "actions.jump_vsplit",
		["<C-s>"] = "actions.jump_split",
		["p"] = "actions.scroll",
		["<C-j>"] = "actions.down_and_scroll",
		["<C-k>"] = "actions.up_and_scroll",
		["{"] = "actions.prev",
		["}"] = "actions.next",
		["[["] = "actions.prev_up",
		["]]"] = "actions.next_up",
		["q"] = "actions.close",
		["o"] = "actions.tree_toggle",
		["za"] = "actions.tree_toggle",
		["O"] = "actions.tree_toggle_recursive",
		["zA"] = "actions.tree_toggle_recursive",
		["l"] = "actions.tree_open",
		["zo"] = "actions.tree_open",
		["L"] = "actions.tree_open_recursive",
		["zO"] = "actions.tree_open_recursive",
		["h"] = "actions.tree_close",
		["zc"] = "actions.tree_close",
		["H"] = "actions.tree_close_recursive",
		["zC"] = "actions.tree_close_recursive",
		["zr"] = "actions.tree_increase_fold_level",
		["zR"] = "actions.tree_open_all",
		["zm"] = "actions.tree_decrease_fold_level",
		["zM"] = "actions.tree_close_all",
		["zx"] = "actions.tree_sync_folds",
		["zX"] = "actions.tree_sync_folds",
	},

	-- When true, don't load aerial until a command or function is called
	-- Defaults to true, unless `on_attach` is provided, then it defaults to false
	lazy_load = true,

	-- Disable aerial on files with this many lines
	disable_max_lines = 10000,

	-- Disable aerial on files this size or larger (in bytes)
	disable_max_size = 2000000, -- Default 2MB

	-- A list of all symbols to display. Set to false to display all symbols.
	-- This can be a filetype map (see :help aerial-filetype-map)
	-- To see all available values, see :help SymbolKind
	-- filter_kind = false,
	filter_kind = {
		"Class",
		"Constructor",
		"Enum",
		"Function",
		"Interface",
		"Module",
		"Method",
		"Struct",
	},

	-- Enum: split_width, full_width, last, none
	-- Determines line highlighting mode when multiple splits are visible.
	-- split_width   Each open window will have its cursor location marked in the
	--               aerial buffer. Each line will only be partially highlighted
	--               to indicate which window is at that location.
	-- full_width    Each open window will have its cursor location marked as a
	--               full-width highlight in the aerial buffer.
	-- last          Only the most-recently focused window will have its location
	--               marked in the aerial buffer.
	-- none          Do not show the cursor locations in the aerial window.
	highlight_mode = "split_width",

	-- Highlight the closest symbol if the cursor is not exactly on one.
	highlight_closest = true,

	-- Highlight the symbol in the source buffer when cursor is in the aerial win
	highlight_on_hover = false,

	-- When jumping to a symbol, highlight the line for this many ms.
	-- Set to false to disable
	highlight_on_jump = 300,

	-- Define symbol icons. You can also specify "<Symbol>Collapsed" to change the
	-- icon when the tree is collapsed at that symbol, or "Collapsed" to specify a
	-- default collapsed icon. The default icon set is determined by the
	-- "nerd_font" option below.
	-- If you have lspkind-nvim installed, aerial will use it for icons.
	icons = {},

	-- Control which windows and buffers aerial should ignore.
	-- If close_behavior is "global", focusing an ignored window/buffer will
	-- not cause the aerial window to update.
	-- If open_automatic is true, focusing an ignored window/buffer will not
	-- cause an aerial window to open.
	-- If open_automatic is a function, ignore rules have no effect on aerial
	-- window opening behavior; it's entirely handled by the open_automatic
	-- function.
	ignore = {
		-- Ignore unlisted buffers. See :help buflisted
		unlisted_buffers = true,

		-- List of filetypes to ignore.
		filetypes = {},

		-- Ignored buftypes.
		-- Can be one of the following:
		-- false or nil - No buftypes are ignored.
		-- "special"    - All buffers other than normal buffers are ignored.
		-- table        - A list of buftypes to ignore. See :help buftype for the
		--                possible values.
		-- function     - A function that returns true if the buffer should be
		--                ignored or false if it should not be ignored.
		--                Takes two arguments, `bufnr` and `buftype`.
		buftypes = "special",

		-- Ignored wintypes.
		-- Can be one of the following:
		-- false or nil - No wintypes are ignored.
		-- "special"    - All windows other than normal windows are ignored.
		-- table        - A list of wintypes to ignore. See :help win_gettype() for the
		--                possible values.
		-- function     - A function that returns true if the window should be
		--                ignored or false if it should not be ignored.
		--                Takes two arguments, `winid` and `wintype`.
		wintypes = "special",
	},

	-- When you fold code with za, zo, or zc, update the aerial tree as well.
	-- Only works when manage_folds = true
	link_folds_to_tree = false,

	-- Fold code when you open/collapse symbols in the tree.
	-- Only works when manage_folds = true
	link_tree_to_folds = true,

	-- Use symbol tree for folding. Set to true or false to enable/disable
	-- 'auto' will manage folds if your previous foldmethod was 'manual'
	manage_folds = false,

	-- Set default symbol icons to use patched font icons (see https://www.nerdfonts.com/)
	-- "auto" will set it to true if nvim-web-devicons or lspkind-nvim is installed.
	nerd_font = "auto",

	-- Call this function when aerial attaches to a buffer.
	-- Useful for setting keymaps. Takes a single `bufnr` argument.
	on_attach = nil,

	-- Automatically open aerial when entering supported buffers.
	-- This can be a function (see :help aerial-open-automatic)
	open_automatic = false,

	-- Run this command after jumping to a symbol (false will disable)
	post_jump_cmd = "normal! zz",

	-- When true, aerial will automatically close after jumping to a symbol
	close_on_select = false,

	-- Show box drawing characters for the tree hierarchy
	show_guides = false,

	-- The autocmds that trigger symbols update (not used for LSP backend)
	update_events = "TextChanged,InsertLeave",

	-- Customize the characters used when show_guides = true
	guides = {
		-- When the child item has a sibling below it
		mid_item = "├─",
		-- When the child item is the last in the list
		last_item = "└─",
		-- When there are nested child guides to the right
		nested_top = "│ ",
		-- Raw indentation
		whitespace = "  ",
	},

	-- Options for opening aerial in a floating win
	float = {
		-- Controls border appearance. Passed to nvim_open_win
		border = "rounded",

		-- Enum: cursor, editor, win
		--   cursor - Opens float on top of the cursor
		--   editor - Opens float centered in the editor
		--   win    - Opens float centered in the window
		relative = "cursor",

		-- These control the height of the floating window.
		-- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
		-- min_height and max_height can be a list of mixed types.
		-- min_height = {8, 0.1} means "the greater of 8 rows or 10% of total"
		max_height = 0.9,
		height = nil,
		min_height = { 8, 0.1 },

		override = function(conf)
			-- This is the config that will be passed to nvim_open_win.
			-- Change values here to customize the layout
			return conf
		end,
	},

	lsp = {
		-- Fetch document symbols when LSP diagnostics update.
		-- If false, will update on buffer changes.
		diagnostics_trigger_update = true,

		-- Set to false to not update the symbols when there are LSP errors
		update_when_errors = true,
	},

	treesitter = {
		-- How long to wait (in ms) after a buffer change before updating
		update_delay = 300,
	},

	markdown = {
		-- How long to wait (in ms) after a buffer change before updating
		update_delay = 300,
	},
})

-- search & replace --
require("spectre").setup({
	live_update = true,
	is_insert_mode = false,
	is_block_ui_break = true,
	use_trouble_qf = true,
	find_engine = {
		["rg"] = {
			cmd = "rg",
			-- default args
			args = {
				"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
			},
			options = {
				["ignore-case"] = {
					value = "--ignore-case",
					icon = "[I]",
					desc = "ignore case",
				},
				["hidden"] = {
					value = "--hidden",
					desc = "hidden file",
					icon = "[H]",
				},
				["line"] = {
					value = "-x",
					icon = "[L]",
					desc = "match in line",
				},
				["word"] = {
					value = "-w",
					icon = "[W]",
					desc = "match in word",
				},
				-- you can put any rg search option you want here it can toggle with
				-- show_option function
			},
		},
	},
	default = {
		find = {
			--pick one of item in find_engine
			cmd = "rg",
			options = { "word", "hidden" },
		},
		replace = {
			--pick one of item in replace_engine
			cmd = "sed",
		},
	},
})

local minimap = require("mini.map")
minimap.setup({
	integrations = {
		minimap.gen_integration.builtin_search(),
		minimap.gen_integration.gitsigns(),
		minimap.gen_integration.diagnostic(),
	},
	symbols = {
		encode = minimap.gen_encode_symbols.dot("3x2"),
	},
})
