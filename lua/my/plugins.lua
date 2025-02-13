return {
	{
		"folke/lazy.nvim",
		tag = "stable",
	},
	-- utils plugins
	"tpope/vim-repeat",
	{
		"kylechui/nvim-surround",
		config = function()
			require("nvim-surround").setup({
				keymaps = {
					insert = "<C-g>s",
					insert_line = "<C-g>S",
					normal = "ys",
					normal_cur = "yys",
					normal_line = "yS",
					normal_cur_line = "yyS",
					visual = "S",
					visual_line = "gS",
					delete = "ds",
					change = "cs",
				},
			})
		end,
	},
	{
		"2kabhishek/nerdy.nvim",
		dependencies = {
			"stevearc/dressing.nvim",
		},
		cmd = "Nerdy",
		config = function() end,
	},
	"phaazon/hop.nvim",

	-- tmux
	{
		"aserowy/tmux.nvim",
		config = function()
			return require("tmux").setup({
				navigation = {
					-- cycles to opposite pane while navigating into the border
					cycle_navigation = true,

					-- enables default keybindings (C-hjkl) for normal mode
					enable_default_keybindings = false,

					-- prevents unzoom tmux when navigating beyond vim border
					persist_zoom = false,
				},
			})
		end,
	},
	-- session
	{ "rmagatti/auto-session", lazy = false },
	"folke/which-key.nvim",

	-- dialog ui
	"stevearc/dressing.nvim",
	-- common dependencies
	"nvim-lua/popup.nvim",
	"nvim-lua/plenary.nvim",
	"kyazdani42/nvim-web-devicons",

	-- auto completion
	{
		"saghen/blink.compat",
		-- use the latest release, via version = '*', if you also use the latest release for blink.cmp
		version = "*",
		-- lazy.nvim will automatically load the plugin when it's required by blink.cmp
		lazy = true,
		-- make sure to set opts so that lazy.nvim calls blink.compat's setup
		opts = {},
	},
	{
		"saghen/blink.cmp",
		-- optional: provides snippets for the snippet source
		dependencies = {
			"rafamadriz/friendly-snippets",
			"hrsh7th/cmp-cmdline",
			"giuxtaposition/blink-cmp-copilot",
		},

		-- use a release tag to download pre-built binaries
		version = "*",
	},
	-- nvim and plugins api completion
	{ "folke/neodev.nvim", opts = {
		library = { plugins = { "nvim-dap-ui" }, types = true },
	} },

	-- neo tree

	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			"stevearc/dressing.nvim",
		},
	},

	-- theme
	"sainnhe/sonokai",

	-- statusline
	"nvim-lualine/lualine.nvim",
	-- terminal
	"akinsho/nvim-toggleterm.lua",

	-- treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
	},
	"nvim-treesitter/nvim-treesitter-textobjects",
	"JoosepAlviste/nvim-ts-context-commentstring",

	-- lsp
	"williamboman/mason.nvim", -- simple to use language server installer
	"williamboman/mason-lspconfig.nvim",
	"neovim/nvim-lspconfig", -- enable LSP
	"tamago324/nlsp-settings.nvim", -- language server settings defined in json for
	"onsails/lspkind.nvim",
	-- formatter
	{
		"stevearc/conform.nvim",
		event = { "BufReadPre", "BufNewFile" },
	},
	-- linter
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
	},
	"folke/trouble.nvim",

	{
		"nvimdev/lspsaga.nvim",
		event = "LspAttach",
		dependencies = {
			"nvim-treesitter/nvim-treesitter", -- optional
			"nvim-tree/nvim-web-devicons", -- optional
		},
	},

	-- DAP
	-- "mfussenegger/nvim-dap",
	-- {
	-- 	"theHamsta/nvim-dap-virtual-text",
	-- 	dependencies = {
	-- 		"nvim-neotest/nvim-nio",
	-- 		"mfussenegger/nvim-dap",
	-- 		"nvim-treesitter/nvim-treesitter",
	-- 	},
	-- },
	-- "rcarriga/nvim-dap-ui",

	-- dev
	{ "echasnovski/mini.map", version = false },
	"windwp/nvim-autopairs",
	"numToStr/Comment.nvim",
	"stevearc/aerial.nvim",
	{ "kevinhwang91/nvim-ufo", dependencies = "kevinhwang91/promise-async" },
	{ "windwp/nvim-spectre" }, -- on Mac: brew install gnu-sed
	-- bufferline
	{ "akinsho/bufferline.nvim", dependencies = "kyazdani42/nvim-web-devicons" },

	-- git
	"lewis6991/gitsigns.nvim",
	"tpope/vim-fugitive",
	"sindrets/diffview.nvim",
	"akinsho/git-conflict.nvim",

	-- programming languages
	"nkrkv/nvim-treesitter-rescript",
	"aspeddro/rescript-tools.nvim",

	"reasonml-editor/vim-reason-plus",
	"dmmulroy/tsc.nvim",
	"simrat39/rust-tools.nvim",
	{
		"ziglang/zig.vim",
		config = function()
			vim.g.zig_std_dir = "/Users/jackzj/.zig/zig-current/lib/std"
		end,
	},
	{
		"pmizio/typescript-tools.nvim",
		dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
		opts = {},
	},

	-- finder
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
	},

	-- quickfix
	{ "kevinhwang91/nvim-bqf", ft = "qf" },
	{
		"junegunn/fzf",
		build = function()
			vim.fn["fzf#install"]()
		end,
	},
	-- ai
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		config = function()
			require("copilot").setup({
				suggestion = { enabled = false },
				panel = { enabled = false },
				filetypes = {
					javascript = true, -- allow specific filetype
					typescript = true, -- allow specific filetype
					zig = true,
					rescript = true,
					-- ["*"] = false, -- disable for all other filetypes and ignore default `filetypes`
				},
			})
		end,
	},
}
