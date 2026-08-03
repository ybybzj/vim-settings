-- sidekick.nvim: NES (Next Edit Suggestions) only
-- CLI mode disabled by design (agent CLIs like pi provide their own TUI)
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
		-- CLI disabled by design (pi provides its own TUI)
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
