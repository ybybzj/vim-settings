-- sidekick.nvim: NES (Next Edit Suggestions) only
-- CLI interactions are handled by opencode.nvim
return {
	"folke/sidekick.nvim",
	dependencies = {
		"zbirenbaum/copilot.lua",
	},
	opts = {
		nes = {
			enabled = true,
			debounce = 100,
		},
		-- CLI disabled - handled by opencode.nvim
		cli = {
			enabled = false,
		},
	},
	keys = {
		-- Tab: NES jump/apply, fallback to normal tab
		{
			"<Tab>",
			function()
				if not require("sidekick").nes_jump_or_apply() then
					return "<Tab>"
				end
			end,
			expr = true,
			mode = { "n", "i" },
			desc = "NES Jump/Apply or Tab",
		},
	},
}
