return {
	{
		"rmagatti/auto-session",
		lazy = false,
		opts = {
			auto_save_enabled = false,
			auto_restore_enabled = false,
			allowed_dirs = { "~/workspace/", "~/.config/nvim/" },
		},
		keys = {
			{ "<space>ss", "<cmd>SessionSearch<cr>", desc = "Select Session" },
			{ "<space>sr", "<cmd>SessionRestore<cr>", desc = "Restore Session" },
			{ "<space>sw", "<cmd>SessionSave<cr>", desc = "Save Session" },
			{ "<space>sa", "<cmd>SessionToggleAutoSave<cr>", desc = "Toggle AutoSave Session" },
		},
	},
}
