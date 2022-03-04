require("toggleterm").setup({
	size = function(term)
		if term.direction == "horizontal" then
			return 15
		elseif term.direction == "vertical" then
			return vim.o.columns * 0.4
		end
	end,
	open_mapping = [[<c-\>]],
	direction = "horizontal",
	close_on_exit = true,
})

-- local Terminal = require("toggleterm.terminal").Terminal
-- local devTerm = Terminal:new({ size = 15, hidden = true, direction = "horizontal", close_on_exit = true })
--
-- _G._devTerm_toggle = function()
-- 	devTerm:toggle()
-- end
--
-- local mapkey = require("shared").mapkey
-- mapkey("n", "<M-\\>", "<cmd>lua _devTerm_toggle()<cr>", { noremap = true, silent = true })
