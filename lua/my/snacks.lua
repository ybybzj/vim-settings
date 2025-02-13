local snacks = require("snacks")

local picker = {
	enabled = true,
	layout = {
		cycle = true,
		preset = "dropdown",
		layout = { width = 0.8, min_width = 120 },
	},
	formatters = {
		file = {
			truncate = 400,
		},
	},
}

local opts = {
	-- your configuration comes here
	-- or leave it empty to use the default settings
	-- refer to the configuration section below
	bigfile = { enabled = true },
	dashboard = { enabled = false },
	explorer = { enabled = false },
	indent = { enabled = true },
	input = { enabled = true },
	picker = picker,
	notifier = { enabled = true },
	quickfile = { enabled = true },
	scope = { enabled = true },
	scroll = { enabled = true },
	statuscolumn = { enabled = true },
	words = { enabled = true },
	git = { enabled = true },
	terminal = { enabled = false },
}
snacks.setup(opts)
