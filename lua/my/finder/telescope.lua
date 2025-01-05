local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
	return
end

local actions = require("telescope.actions")

local shared_layout = {
	width = 0.9,
	scroll_speed = 1,
	prompt_position = "top",
	preview_cutoff = 20,
	-- preview_height = 0.3,
	anchor = "N",
}

telescope.setup({
	defaults = {
		prompt_prefix = " ",
		selection_caret = " ",
		dynamic_preview_title = true,
		path_display = { "smart" },
		scroll_strategy = "limit",
		layout_strategy = "vertical",
		sorting_strategy = "ascending",
		layout_config = shared_layout,
		mappings = {
			i = {
				["<C-n>"] = actions.cycle_history_next,
				["<C-p>"] = actions.cycle_history_prev,

				["<C-j>"] = actions.move_selection_next,
				["<C-k>"] = actions.move_selection_previous,

				["<C-c>"] = actions.close,

				["<Down>"] = actions.move_selection_next,
				["<Up>"] = actions.move_selection_previous,

				["<CR>"] = actions.select_default,
				["<C-x>"] = actions.select_horizontal,
				["<C-v>"] = actions.select_vertical,
				["<C-t>"] = actions.select_tab,

				["<C-u>"] = actions.preview_scrolling_up,
				["<C-d>"] = actions.preview_scrolling_down,

				["<PageUp>"] = actions.results_scrolling_up,
				["<PageDown>"] = actions.results_scrolling_down,

				["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
				["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
				["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
				["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
				["<C-l>"] = actions.complete_tag,
				["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
				["<ScrollWheelDown>"] = actions.preview_scrolling_down,
				["<ScrollWheelUp>"] = actions.preview_scrolling_up,
			},

			n = {
				["<esc>"] = actions.close,
				["<CR>"] = actions.select_default,
				["<C-x>"] = actions.select_horizontal,
				["<C-v>"] = actions.select_vertical,
				["<C-t>"] = actions.select_tab,

				["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
				["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
				["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
				["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

				["j"] = actions.move_selection_next,
				["k"] = actions.move_selection_previous,
				["H"] = actions.move_to_top,
				["M"] = actions.move_to_middle,
				["L"] = actions.move_to_bottom,

				["<Down>"] = actions.move_selection_next,
				["<Up>"] = actions.move_selection_previous,
				["gg"] = actions.move_to_top,
				["G"] = actions.move_to_bottom,

				["<C-u>"] = actions.preview_scrolling_up,
				["<C-d>"] = actions.preview_scrolling_down,
				["<ScrollWheelDown>"] = actions.preview_scrolling_down,
				["<ScrollWheelUp>"] = actions.preview_scrolling_up,

				["<PageUp>"] = actions.results_scrolling_up,
				["<PageDown>"] = actions.results_scrolling_down,

				["?"] = actions.which_key,
			},
		},
	},
	vimgrep_arguments = {
		"rg",
		"--color=never",
		"--no-heading",
		"--with-filename",
		"--line-number",
		"--column",
		"--hidden",
	},
	pickers = {
		-- Default configuration for builtin pickers goes here:
		find_files = {
			path_display = { "absolute" },
		},
		oldfiles = {
			path_display = { "absolute" },
			initial_mode = "normal",
		},
		lsp_references = {
			path_display = { "absolute" },
			initial_mode = "normal",
		},
		live_grep = {
			additional_args = function(opts)
				local args = {}
				local case = opts.case
				if case == "smart" then
					table.insert(args, "--smart-case")
				elseif case == "ignore" then
					table.insert(args, "--ignore-case")
				else
					table.insert(args, "--case-sensitive")
				end
				return args
			end,
		},
		grep_string = {
			additional_args = function(opts)
				local args = {}
				local case = opts.case
				if case == "smart" then
					table.insert(args, "--smart-case")
				elseif case == "ignore" then
					table.insert(args, "--ignore-case")
				else
					table.insert(args, "--case-sensitive")
				end
				--
				-- table.insert(args, "--")
				--
				-- local search = opts.search
				--
				-- if not search or #search == 0 then
				-- 	if opts.search_cword then
				-- 		search = "'\\b" .. vim.fn.expand("<cword>") .. "\\b'"
				-- 	else
				-- 		search = "'" .. vim.fn.input(">?") .. "'"
				-- 	end
				-- end
				--
				-- table.insert(args, search)
				return args
			end,
		},
		-- Now the picker_config_key will be applied every time you call this
		-- builtin picker
	},
	extensions = {
		-- Your extension configuration goes here:
		-- extension_name = {
		--   extension_config_key = value,
		-- }
		-- please take a look at the readme of the extension you want to configure
		fzf = {
			fuzzy = true, -- false will only do exact matching
			override_generic_sorter = true, -- override the generic sorter
			override_file_sorter = true, -- override the file sorter
			case_mode = "smart_case", -- or "ignore_case" or "respect_case"
			-- the default case_mode is "smart_case"
		},
	},
})

telescope.load_extension("fzf")
telescope.load_extension("aerial")
-- telescope.load_extension("software-licenses")
telescope.load_extension("conventional_commits")
telescope.load_extension("git_diffs")
