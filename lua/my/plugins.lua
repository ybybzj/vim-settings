local fn = vim.fn
local cmd = vim.cmd

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})

	print("Installing packer close and reopen Neovim...")

	cmd("packadd packer.nvim")
end

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

return packer.startup({
	function(use)
		-- My plugins here
		use("wbthomason/packer.nvim") -- Have packer manage itself
		-- utils plugins
		use("tpope/vim-repeat")
		-- use("tpope/vim-surround")
		use({
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
		})

		use("tversteeg/registers.nvim")
		use("folke/zen-mode.nvim")
		use("folke/twilight.nvim")
		use("karb94/neoscroll.nvim")
		use("phaazon/hop.nvim")

		use("antoinemadec/FixCursorHold.nvim") -- This is needed to fix lsp doc highlight
		use("folke/which-key.nvim")

		-- dialog ui
		use({ "stevearc/dressing.nvim" })
		-- common dependencies
		use("nvim-lua/popup.nvim")
		use("nvim-lua/plenary.nvim")
		use("kyazdani42/nvim-web-devicons")
		-- enable reload lua settings
		use("famiu/nvim-reload")

		-- auto completion
		use("hrsh7th/nvim-cmp")
		use("hrsh7th/cmp-nvim-lsp")
		use("hrsh7th/cmp-buffer")
		use("hrsh7th/cmp-path")
		use("hrsh7th/cmp-cmdline")
		use("hrsh7th/cmp-nvim-lua")
		use("hrsh7th/cmp-emoji")
		-- snippet
		use("L3MON4D3/LuaSnip")
		use("rafamadriz/friendly-snippets")
		use("saadparwaiz1/cmp_luasnip")

		-- neo tree

		use({
			"nvim-neo-tree/neo-tree.nvim",
			branch = "v2.x",
			requires = {
				"nvim-lua/plenary.nvim",
				"kyazdani42/nvim-web-devicons", -- not strictly required, but recommended
				"MunifTanjim/nui.nvim",
			},
		})

		-- theme
		-- use("shaunsingh/nord.nvim")
		-- use("marko-cerovac/material.nvim")
		-- use("EdenEast/nightfox.nvim")
		use("sainnhe/sonokai")
		-- use("folke/tokyonight.nvim")
		-- use("folke/lsp-colors.nvim")

		-- statusline
		use("nvim-lualine/lualine.nvim")
		-- terminal
		use("akinsho/nvim-toggleterm.lua")

		-- treesitter
		use({
			"nvim-treesitter/nvim-treesitter",
			run = function()
				local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
				ts_update()
			end,
		})
		use({ "nvim-treesitter/nvim-treesitter-textobjects" })
		use("JoosepAlviste/nvim-ts-context-commentstring")

		-- lsp
		use("williamboman/mason.nvim") -- simple to use language server installer
		use("williamboman/mason-lspconfig.nvim")
		use("neovim/nvim-lspconfig") -- enable LSP
		use("tamago324/nlsp-settings.nvim") -- language server settings defined in json for
		use("jose-elias-alvarez/null-ls.nvim") -- for formatters and linters
		use("folke/trouble.nvim")
		use({
			"glepnir/lspsaga.nvim",
			branch = "main",
		})

		-- dev
		use("wfxr/minimap.vim")
		use("windwp/nvim-autopairs")
		use("numToStr/Comment.nvim")
		use("lukas-reineke/indent-blankline.nvim")
		use({ "stevearc/aerial.nvim" })
		use({ "kevinhwang91/nvim-ufo", requires = "kevinhwang91/promise-async" })
		-- bufferline
		use({ "akinsho/bufferline.nvim", requires = "kyazdani42/nvim-web-devicons" })

		-- git
		use("lewis6991/gitsigns.nvim")
		use("tpope/vim-fugitive")
		use("sindrets/diffview.nvim")
		use("akinsho/git-conflict.nvim")

		-- programming languages
		use("rescript-lang/vim-rescript")
		use("reasonml-editor/vim-reason-plus")
		use("jose-elias-alvarez/nvim-lsp-ts-utils")
		use("simrat39/rust-tools.nvim")
		use("ziglang/zig.vim")

		-- finder
		use({ "nvim-telescope/telescope.nvim", branch = "0.1.x" })
		use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
		-- use({ "nvim-telescope/telescope-ui-select.nvim" })

		-- quickfix
		use({ "kevinhwang91/nvim-bqf", ft = "qf" })
		use({
			"junegunn/fzf",
			run = function()
				vim.fn["fzf#install"]()
			end,
		})
		-- copilot
		-- use("github/copilot.vim")
		-- use({
		-- 	"zbirenbaum/copilot.lua",
		-- 	event = "VimEnter",
		-- 	config = function()
		-- 		vim.defer_fn(function()
		-- 			require("copilot").setup({
		-- 				-- cmp = {
		-- 				-- 	enabled = true,
		-- 				-- 	method = "getPanelCompletions",
		-- 				-- },
		-- 				-- panel = { -- no config options yet
		-- 				-- 	enabled = true,
		-- 				-- },
		-- 				-- ft_disable = {},
		-- 				-- plugin_manager_path = vim.fn.stdpath("data") .. "/site/pack/packer",
		-- 				-- server_opts_overrides = {},
		-- 			})
		-- 		end, 100)
		-- 	end,
		-- })
		-- use({
		-- 	"zbirenbaum/copilot-cmp",
		-- 	module = "copilot_cmp",
		-- })
		-- Automatically set up your configuration after cloning packer.nvim
		-- Put this at the end after all plugins
		if PACKER_BOOTSTRAP then
			require("packer").sync()
		end
	end,

	config = {
		git = {
			clone_timeout = 1600,
		},
	},
})
