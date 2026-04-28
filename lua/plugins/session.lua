return {
	{
		"rmagatti/auto-session",
		lazy = false,
		opts = {
			auto_save = false,
			auto_restore = false,
			show_auto_restore_notif = true,
			allowed_dirs = {
				"~/workplace/*",
				"~/workplace/*/*",
				"~/workplace/*/*/*",
				"~/workplace/*/*/*/*",
				"~/.config/nvim/",
			},
			session_lens = {
				picker = "snacks",
				load_on_setup = false,
				picker_opts = {
					preset = "vertical",
				},
				previewer = function(session_name, session_filename, session_lines)
					return require("workspace.session").preview(session_name, session_filename, session_lines)
				end,
			},
			pre_save_cmds = {
				function(_)
					return require("workspace.session").pre_save()
				end,
			},
			post_restore_cmds = {
				function(_)
					require("workspace.session").post_restore()
				end,
			},
			save_extra_data = function(_)
				return require("workspace.session").save()
			end,
			restore_extra_data = function(session_name, extra_data)
				require("workspace.session").restore(session_name, extra_data)
			end,
		},
		keys = {
			{ "<space>ss", function() require("workspace.session").search() end, desc = "Select Session" },
			{ "<space>sr", function() require("workspace.session").restore() end, desc = "Restore Session" },
			{ "<space>sw", "<cmd>SessionSave<cr>", desc = "Save Session" },
			{ "<space>sa", "<cmd>SessionToggleAutoSave<cr>", desc = "Toggle AutoSave Session" },
		},
	},
}
