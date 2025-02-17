-- tmux
local map = vim.keymap.set
return	{
		"aserowy/tmux.nvim",
		config = function()
      local tmux = require("tmux")
			tmux.setup({
				navigation = {
					-- cycles to opposite pane while navigating into the border
					cycle_navigation = true,

					-- enables default keybindings (C-hjkl) for normal mode
					enable_default_keybindings = false,

					-- prevents unzoom tmux when navigating beyond vim border
					persist_zoom = false,
				},
			})
      -- tmux navigation
      map("", "<C-Left>", '<cmd>lua require("tmux").move_left()<cr>')
      map("", "<C-Right>", '<cmd>lua require("tmux").move_right()<cr>')
      map("", "<C-Up>", '<cmd>lua require("tmux").move_top()<cr>')
      map("", "<C-Down>", '<cmd>lua require("tmux").move_bottom()<cr>')
		end,
	}

