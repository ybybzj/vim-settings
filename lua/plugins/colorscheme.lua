local cmd = vim.cmd
local g = vim.g

return {
	{
		"sainnhe/sonokai",
		enabled = true,
		config = function()
			------------------theme-------------------------
			cmd("set background=dark")
			-- Available values: `'default'`, `'atlantis'`, `'andromeda'`, `'shusia'`, `'maia'`, `'espresso'`
			g.sonokai_style = "atlantis"
			g.sonokai_enable_italic = 1
			g.sonokai_disable_italic_comment = 1
			g.sonokai_transparent_background = 1
			g.sonokai_diagnostic_text_highlight = 1
			g.sonokai_current_word = "grey background"
			cmd("colorscheme sonokai")
		end,
	},
}
