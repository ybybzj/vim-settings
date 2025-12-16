return {
	-- Supermaven: inline ghost text completions (fast, 1M context)
	{
		"supermaven-inc/supermaven-nvim",
		config = function()
			require("supermaven-nvim").setup({
				ignore_filetypes = { "copilot-chat", "copilot-overlay" },
			})
		end,
	},
	-- Copilot.lua: backend for sidekick.nvim NES (no inline suggestions)
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		config = function()
			require("copilot").setup({
				suggestion = { enabled = false },
				panel = { enabled = false },
			})
		end,
	},
}
