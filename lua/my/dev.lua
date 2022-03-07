-- hopper setting --
require("hop").setup()

-- diagnostic tool
require("trouble").setup({
	-- your configuration comes here
	-- or leave it empty to use the default settings
	-- refer to the configuration section below
})

-- autopairs
require("nvim-autopairs").setup({})

-- blank indent line
require("indent_blankline").setup({
	show_end_of_line = true,
})
