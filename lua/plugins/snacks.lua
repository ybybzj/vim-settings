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

local function with_workspace_ui(action, fallback)
	return function()
		local ok, workspace = pcall(require, "workspace")
		if ok and workspace.is_open() then
			require("workspace.ui")[action]()
			return
		end
		fallback()
	end
end

local function open_lazygit()
	-- Neo-tree's git_status source refreshes on repository changes, which competes
	-- with lazygit and makes the TUI noticeably sluggish while both are open.
	pcall(function()
		require("neo-tree.command").execute({ action = "close", source = "git_status", position = "left" })
	end)
	Snacks.lazygit()
end

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
		terminal = { enabled = true },
		lazygit = {},
	},
	keys = {
		-- git --
		{ "<space>gg", open_lazygit, desc = "GitUI (Snacks)" },
		{ "<leader>gg", open_lazygit, desc = "GitUI (Snacks)" },
		{ "<space>gl", "<cmd>lua Snacks.git.blame_line()<cr>", desc = "Blame" },
		{ "<space>go", "<cmd>lua Snacks.picker.git_status()<cr>", desc = "Open changed file" },
		{ "<space>gb", "<cmd>lua Snacks.picker.git_branches()<cr>", desc = "Checkout branch" },
		{ "<space>gcl", "<cmd>lua Snacks.picker.git_log_line()<cr>", desc = "Browse Line Commits" },
		{ "<space>gcc", "<cmd>lua Snacks.picker.git_log()<cr>", desc = "Checkout commit" },
		-- finder --
		{ "<space>fo", "<cmd>lua Snacks.picker.recent()<cr>", desc = "find recent files" },
		{ "<space>ff", with_workspace_ui("context_smart_files", function() Snacks.picker.smart() end), desc = "find files smart" },
		{ "<space>fF", with_workspace_ui("context_files", function() Snacks.picker.files() end), desc = "find files" },
		{ "<space>fb", with_workspace_ui("workspace_buffers", function() Snacks.picker.buffers() end), desc = "find buffers" },
		{ "<space>fg", with_workspace_ui("context_grep", function() Snacks.picker.grep() end), desc = "live grep with case sensitive" },
		{
			"<space>fw",
			with_workspace_ui("context_grep_word", function() Snacks.picker.grep_word() end),
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
