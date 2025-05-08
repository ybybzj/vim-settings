local cmd = vim.cmd
local g = vim.g

return {
	{
		"sainnhe/sonokai",
		enabled = false,
		lazy = false,
		priority = 1000, -- make sure to load this before all the other start plugins
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
	{
		"neanias/everforest-nvim",
		enabled = false,
		lazy = false,
		priority = 1000, -- make sure to load this before all the other start plugins
		-- Optional; default configuration will be used if setup isn't called.
		config = function()
			cmd("set background=dark")
			local everforest = require("everforest")
			everforest.setup({
				background = "soft",
				transparent_background_level = 1,
				italics = true,
				disable_italic_comments = false,
				-- on_highlights = function(hl, _)
				-- 	hl["@string.special.symbol.ruby"] = { link = "@field" }
				-- end,
			})
			everforest.load()
		end,
	},
	{
		"rebelot/kanagawa.nvim",
		enabled = true,
		lazy = false,
		priority = 1000, -- make sure to load this before all the other start plugins
		config = function()
			cmd("set background=dark")
			local kanagawa = require("kanagawa")
			kanagawa.setup({
				transparent = false,
			})
			-- cmd("colorscheme kanagawa-wave")
			cmd("colorscheme kanagawa-dragon")
			-- cmd("colorscheme kanagawa-lotus")
		end,
	},
}
