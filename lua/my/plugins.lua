return {
	{
		"folke/lazy.nvim",
		tag = "stable",
	},
	-- utils plugins
	"tpope/vim-repeat",
	-- "tpope/vim-surround",
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

	"tversteeg/registers.nvim",
	"folke/zen-mode.nvim",
	"folke/twilight.nvim",
	"karb94/neoscroll.nvim",
	"phaazon/hop.nvim",

	-- session
	{ "echasnovski/mini.sessions", version = false },
	-- "antoinemadec/FixCursorHold.nvim", -- This is needed to fix lsp doc highlight
	"folke/which-key.nvim",

	-- dialog ui
	"stevearc/dressing.nvim",
	-- common dependencies
	"nvim-lua/popup.nvim",
	"nvim-lua/plenary.nvim",
	"kyazdani42/nvim-web-devicons",
	-- enable reload lua settings
	"famiu/nvim-reload",

	-- auto completion
	"hrsh7th/nvim-cmp",
	"hrsh7th/cmp-nvim-lsp",
	"hrsh7th/cmp-buffer",
	"hrsh7th/cmp-path",
	"hrsh7th/cmp-cmdline",
	"hrsh7th/cmp-nvim-lua",
	"hrsh7th/cmp-emoji",
	{
		"zbirenbaum/copilot-cmp",
		config = function()
			require("copilot_cmp").setup()
		end,
	},
	-- snippet
	{ "L3MON4D3/LuaSnip", dependencies = { "rafamadriz/friendly-snippets" } },
	"saadparwaiz1/cmp_luasnip",

	-- nvim and plugins api completion
	{ "folke/neodev.nvim", opts = {
		library = { plugins = { "nvim-dap-ui" }, types = true },
	} },

	-- neo tree

	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v2.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
		},
	},

	-- theme
	-- "shaunsingh/nord.nvim",
	-- "marko-cerovac/material.nvim",
	-- "EdenEast/nightfox.nvim",
	-- {
	"sainnhe/sonokai",

	-- 	lazy = false, -- make sure we load this during startup if it is your main colorscheme
	-- 	priority = 1000,
	-- },
	-- "folke/tokyonight.nvim",
	-- "folke/lsp-colors.nvim",

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
	-- "jose-elias-alvarez/null-ls.nvim", -- for formatters and linters
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

	"glepnir/lspsaga.nvim",

	-- DAP
	"mfussenegger/nvim-dap",
	{
		"theHamsta/nvim-dap-virtual-text",
		dependencies = {
			"nvim-neotest/nvim-nio",
			"mfussenegger/nvim-dap",
			"nvim-treesitter/nvim-treesitter",
		},
	},
	"rcarriga/nvim-dap-ui",

	-- dev
	{ "echasnovski/mini.map", version = false },
	-- "wfxr/minimap.vim",
	"windwp/nvim-autopairs",
	"numToStr/Comment.nvim",
	"lukas-reineke/indent-blankline.nvim",
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
	"jose-elias-alvarez/nvim-lsp-ts-utils",
	"dmmulroy/tsc.nvim",
	"simrat39/rust-tools.nvim",
	{
		"ziglang/zig.vim",
		config = function()
			vim.g.zig_std_dir = "/Users/jackzj/.zig/zig-current/lib/std"
		end,
	},

	-- finder
	{ "nvim-telescope/telescope.nvim", branch = "0.1.x" },
	{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
	-- { "chip/telescope-software-licenses.nvim" },
	{ "olacin/telescope-cc.nvim" },
	{ "paopaol/telescope-git-diffs.nvim" },
	-- { "nvim-telescope/telescope-ui-select.nvim" },

	-- quickfix
	{ "kevinhwang91/nvim-bqf", ft = "qf" },
	{
		"junegunn/fzf",
		build = function()
			vim.fn["fzf#install"]()
		end,
	},
	-- ai
	-- {
	-- 	"zbirenbaum/copilot.lua",
	-- 	cmd = "Copilot",
	-- 	event = "InsertEnter",
	-- 	config = function()
	-- 		require("copilot").setup({
	-- 			filetypes = {
	-- 				javascript = true, -- allow specific filetype
	-- 				typescript = true, -- allow specific filetype
	-- 				zig = true,
	-- 				["*"] = false, -- disable for all other filetypes and ignore default `filetypes`
	-- 			},
	-- 			suggestion = { enabled = false },
	-- 			panel = { enabled = false },
	-- 		})
	-- 	end,
	-- },
}
