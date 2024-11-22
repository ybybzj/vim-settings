local cmd = vim.cmd

local status, neoTree = pcall(require, "neo-tree")

if not status then
	return
end

cmd("let g:neo_tree_remove_legacy_commands = 1")
vim.fn.sign_define("DiagnosticSignHint", { text = "󰌵", texthl = "DiagnosticSignHint" })
neoTree.setup({
	enable_diagnostics = true,
	open_files_do_not_replace_types = { "terminal", "trouble", "qf", "Spectre", "ctrlsf" },
	auto_clean_after_session_restore = true,
	default_component_configs = {
		icon = {
			folder_empty = "󰜌",
		},
		git_status = {
			symbols = {
				-- Change type
				added = "✚", -- or "✚", but this is redundant info if you use git_status_colors on the name
				modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
				deleted = "✖", -- this can only be used in the git_status source
				renamed = "󰁕", -- this can only be used in the git_status source
				-- Status type
				untracked = "",
				ignored = "",
				unstaged = "󰄱",
				staged = "",
				conflict = "",
			},
		},
	},
	filesystem = {
		follow_current_file = { enable = true },
		hijack_netrw_behavior = "open_current",
		use_libuv_file_watcher = true,
		window = {
			mappings = {
				["H"] = "toggle_hidden",
				["/"] = "fuzzy_finder",
				["D"] = "fuzzy_finder_directory",
				--["/"] = "filter_as_you_type", -- this was the default until v1.28
				-- ["#"] = "fuzzy_sorter", -- fuzzy sorting using the fzy algorithm
				-- ["D"] = "fuzzy_sorter_directory",
				["f"] = "filter_on_submit",
				["<C-x>"] = "clear_filter",
				["<bs>"] = "navigate_up",
				["."] = "set_root",
				["[g"] = "prev_git_modified",
				["]g"] = "next_git_modified",
			},
		},
		filtered_items = {
			visible = false, -- when true, they will just be displayed differently than normal items
			force_visible_in_empty_folder = false, -- when true, hidden files will be shown if the root folder is otherwise empty
			show_hidden_count = true, -- when true, the number of hidden items in each folder will be shown as the last entry
			hide_dotfiles = false,
			hide_gitignored = true,
			hide_hidden = true, -- only works on Windows for hidden files/directories
			hide_by_name = {
				".DS_Store",
				"thumbs.db",
				".git",
				--"node_modules",
			},
			hide_by_pattern = { -- uses glob style patterns
				--"*.meta",
				--"*/src/*/tsconfig.json"
			},
			always_show = { -- remains visible even if other settings would normally hide it
				--".gitignored",
			},
			never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
				--".DS_Store",
				--"thumbs.db"
			},
			never_show_by_pattern = { -- uses glob style patterns
				--".null-ls_*",
			},
		},
	},
	use_default_mappings = false,
	window = {
		mappings = {
			["u"] = "navigate_up",
			["<2-LeftMouse>"] = "open",
			["<cr>"] = "open",
			["<right>"] = "open",
			["<esc>"] = "revert_preview",
			["P"] = { "toggle_preview", config = { use_float = true } },
			["l"] = "focus_preview",
			["S"] = "open_split",
			-- ["S"] = "split_with_window_picker",
			["s"] = "open_vsplit",
			-- ["s"] = "vsplit_with_window_picker",
			["t"] = "open_tabnew",
			-- ["<cr>"] = "open_drop",
			-- ["t"] = "open_tab_drop",
			["w"] = "open_with_window_picker",
			["C"] = "close_node",
			["<left>"] = "close_node",
			["z"] = "close_all_nodes",
			--["Z"] = "expand_all_nodes",
			["R"] = "refresh",
			["a"] = {
				"add",
				-- some commands may take optional config options, see `:h neo-tree-mappings` for details
				config = {
					show_path = "relative", -- "none", "relative", "absolute"
				},
			},
			["A"] = "add_directory", -- also accepts the config.show_path and config.insert_as options.
			["d"] = "delete",
			["r"] = "rename",
			["y"] = "copy_to_clipboard",
			["x"] = "cut_to_clipboard",
			["p"] = "paste_from_clipboard",
			["c"] = "copy", -- takes text input for destination, also accepts the config.show_path and config.insert_as options
			["m"] = "move", -- takes text input for destination, also accepts the config.show_path and config.insert_as options
			["e"] = "toggle_auto_expand_width",
			["q"] = "close_window",
			["?"] = "show_help",
			["<"] = "prev_source",
			[">"] = "next_source",
			["Y"] = "copy_selector",
		},
	},
	commands = {
		-- for copy paths
		copy_selector = function(state)
			local node = state.tree:get_node()
			local filepath = node:get_id()
			local filename = node.name
			local modify = vim.fn.fnamemodify

			local vals = {
				["1.RelPATH"] = modify(filepath, ":."),
				-- ["BASENAME"] = modify(filename, ":r"),
				-- ["EXTENSION"] = modify(filename, ":e"),
				["3.FILENAME"] = filename,
				-- ["PATH (HOME)"] = modify(filepath, ":~"),
				["2.AbsPATH"] = filepath,
				-- ["URI"] = vim.uri_from_fname(filepath),
			}

			local options = vim.tbl_filter(function(val)
				return vals[val] ~= ""
			end, vim.tbl_keys(vals))
			if vim.tbl_isempty(options) then
				vim.notify("No values to copy", vim.log.levels.WARN)
				return
			end
			table.sort(options)
			vim.ui.select(options, {
				prompt = "Choose to copy to clipboard:",
				format_item = function(item)
					return ("%s: %s"):format(item, vals[item])
				end,
			}, function(choice)
				local result = vals[choice]
				if result then
					vim.notify(("Copied: `%s`"):format(result))
					vim.fn.setreg("+", result)
				end
			end)
		end,
	},
})
