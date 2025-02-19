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

return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	init = function()
		vim.g.snacks_animate = false
	end,
	opts = {
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
	},
	keys = {
		-- git --
		{ "<space>gl", "<cmd>lua Snacks.git.blame_line()<cr>", desc = "Blame" },
		{ "<space>go", "<cmd>lua Snacks.picker.git_status()<cr>", desc = "Open changed file" },
		{ "<space>gb", "<cmd>lua Snacks.picker.git_branches()<cr>", desc = "Checkout branch" },
		{ "<space>gcl", "<cmd>lua Snacks.picker.git_log_line()<cr>", desc = "Browse Line Commits" },
		{ "<space>gcc", "<cmd>lua Snacks.picker.git_log()<cr>", desc = "Checkout commit" },
		-- finder --
		{ "<space>fo", "<cmd>lua Snacks.picker.recent()<cr>", desc = "find recent files" },
		{ "<space>ff", "<cmd>lua Snacks.picker.smart()<cr>", desc = "find files smart" },
		{ "<space>fF", "<cmd>lua Snacks.picker.files()<cr>", desc = "find files" },
		{ "<space>fb", "<cmd>lua Snacks.picker.buffers()<cr>", desc = "find buffers" },
		{ "<space>fg", "<cmd>lua Snacks.picker.grep()<cr>", desc = "live grep with case sensitive" },
		{
			"<space>fw",
			"<cmd>lua Snacks.picker.grep_word()<cr>",
			desc = "find word in project",
		},
		{
			"<C-p>",
			"<cmd>lua Snacks.picker.recent()<cr>",
			desc = "find recent files",
		},

		-- lsp --
		{ "<space>lr", "<cmd>lua Snacks.picker.lsp_references()<cr>", desc = "find references" },
		{
			"<space>lS",
			"<cmd>lua Snacks.picker.lsp_workspace_symbols()<cr>",
			desc = "find symbols in workspace",
		},
		{ "<space>ls", "<cmd>lua Snacks.picker.lsp_symbols()<cr>", desc = "find symbols in document with filter" },
		{ "<space>lb", "<cmd>lua Snacks.picker.diagnostics_buffer()<cr>", desc = "list diagnostics in buffer" },

		-- extras --
		{
			"<leader>zm",
			":lua Snacks.zen()<cr>",
			desc = "Toggle Zen Mode",
		},
	},
}
