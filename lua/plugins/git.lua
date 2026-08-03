local signs = {
	add = { text = "▎" },
	change = { text = "▎" },
	delete = { text = "󰐊" },
	topdelete = { text = "󰐊" },
	changedelete = {
		text = "▎",
	},
	untracked = { text = "┆" },
}

local hunk_focus = require("config.git_hunk_focus")
local current_hunk_diff = require("config.current_hunk_diff")

-- Hunk navigation for the diff review workflow (AI-review tooling, was opencode.nvim)
local function with_mini_diff(callback)
	local ok, mini_diff = pcall(require, "mini.diff")
	if not ok then
		vim.notify("mini.diff is not available", vim.log.levels.WARN)
		return
	end
	mini_diff.enable(0)
	callback(mini_diff)
end

local function goto_diff_hunk(direction)
	with_mini_diff(function(mini_diff)
		mini_diff.goto_hunk(direction)
	end)
end

return {
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			signs = signs,
			signs_staged = signs,
			signs_staged_enable = true,
			signcolumn = true, -- Toggle with `:Gitsigns toggle_signs`
			numhl = false, -- Toggle with `:Gitsigns toggle_numhl`
			linehl = false, -- Toggle with `:Gitsigns toggle_linehl`
			word_diff = false, -- Toggle with `:Gitsigns toggle_word_diff`
			watch_gitdir = {
				interval = 1000,
				follow_files = true,
			},
			attach_to_untracked = true,
			current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
			current_line_blame_opts = {
				virt_text = true,
				virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
				delay = 1000,
				ignore_whitespace = false,
			},
			current_line_blame_formatter = "<author>, <author_time:%R> - <summary>",
			sign_priority = 6,
			update_debounce = 100,
			status_formatter = nil, -- Use default
			max_file_length = 40000,
			preview_config = {
				-- Options passed to nvim_open_win
				border = "single",
				style = "minimal",
				relative = "cursor",
				row = 0,
				col = 1,
			},
		},
		keys = {
			{ "]h", "<cmd>lua require('gitsigns').nav_hunk('next')<cr>", desc = "Next Git Hunk" },
			{ "[h", "<cmd>lua require('gitsigns').nav_hunk('prev')<cr>", desc = "Prev Git Hunk" },
			{ "<space>ghd", hunk_focus.toggle, desc = "Toggle Git Hunk Focus" },
			{ "<space>ghj", "<cmd>lua require('gitsigns').nav_hunk('next')<cr>", desc = "Next Hunk" },
			{ "<space>ghk", "<cmd>lua require('gitsigns').nav_hunk('prev')<cr>", desc = "Prev Hunk" },
			{ "<space>ghp", "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", desc = "Preview Hunk" },
			{ "<space>ghr", "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", desc = "Reset Hunk" },
			{ "<space>ghR", "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", desc = "Reset Buffer" },
			{ "<space>ghs", "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", desc = "Stage Hunk" },
			{ "<space>ghu", "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", desc = "Undo Stage Hunk" },
		},
	},
	{
		"nvim-mini/mini.diff",
		version = false,
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			view = {
				style = "sign",
				signs = { add = signs.add.text, change = signs.change.text, delete = signs.delete.text },
			},
			mappings = {
				apply = "gh",
				reset = "gH",
				textobject = "gh",
				goto_first = "",
				goto_prev = "",
				goto_next = "",
				goto_last = "",
			},
		},
		keys = {
			{ "<space>gd", current_hunk_diff.toggle, desc = "Toggle Current Hunk Diff" },
			{ "<space>gfd", current_hunk_diff.toggle_buffer_overlay, desc = "Toggle Buffer Diff Overlay" },
			{ "<space>gD", current_hunk_diff.toggle_tracking, desc = "Toggle Buffer Diff Tracking" },
			{ "<space>gfh", current_hunk_diff.toggle, desc = "Toggle Current Hunk Diff" },
			-- Diff review workflow (formerly under <space>a*, moved here when opencode.nvim was dropped)
			{ "<space>grw", current_hunk_diff.show, desc = "Review Current Hunk Diff" },
			{ "<space>grh", current_hunk_diff.show, desc = "Review Current Hunk Diff" },
			{ "<space>grj", function() goto_diff_hunk("next") end, desc = "Next Hunk" },
			{ "<space>grk", function() goto_diff_hunk("prev") end, desc = "Prev Hunk" },
			{ "<space>grp", current_hunk_diff.toggle, desc = "Toggle Current Hunk Diff" },
			{ "<space>grb", current_hunk_diff.toggle_buffer_overlay, desc = "Toggle Buffer Diff Overlay" },
			{ "<space>grq", current_hunk_diff.clear, desc = "Close Diff Review" },
		},
		cmd = { "DiffReview" },
		config = function(_, opts)
			require("mini.diff").setup(opts)
			vim.api.nvim_create_user_command("DiffReview", function()
				current_hunk_diff.show()
			end, { desc = "Open current hunk diff review" })
		end,
	},
}
