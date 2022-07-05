local fn = vim.fn

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
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

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
					-- Configuration here, or leave empty to use defaults
					keymaps = { -- vim-surround style keymaps
						insert = "ys",
						visual = "S",
						delete = "ds",
						change = "cs",
					},
					delimiters = {
						pairs = {
							["("] = { "( ", " )" },
							[")"] = { "(", ")" },
							["{"] = { "{ ", " }" },
							["}"] = { "{", "}" },
							["<"] = { "< ", " >" },
							[">"] = { "<", ">" },
							["["] = { "[ ", " ]" },
							["]"] = { "[", "]" },
						},
						separators = {
							["'"] = { "'", "'" },
							['"'] = { '"', '"' },
							["`"] = { "`", "`" },
						},
						HTML = {
							["t"] = true, -- Use "t" for HTML-style mappings
						},
						aliases = {
							["a"] = ">", -- Single character aliases apply everywhere
							["b"] = ")",
							["B"] = "}",
							["r"] = "]",
							["q"] = { '"', "'", "`" }, -- Table aliases only apply for changes/deletions
						},
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

		-- nerd tree
		use("ryanoasis/vim-devicons")
		use("preservim/nerdtree")
		use("Xuyuanp/nerdtree-git-plugin")
		use("tiagofumo/vim-nerdtree-syntax-highlight")

		-- theme
		use("shaunsingh/nord.nvim")
		use("marko-cerovac/material.nvim")
		use("EdenEast/nightfox.nvim")
		use("sainnhe/sonokai")

		-- statusline
		use("nvim-lualine/lualine.nvim")
		-- terminal
		use("akinsho/nvim-toggleterm.lua")

		-- treesitter
		use({
			"nvim-treesitter/nvim-treesitter",
			run = ":TSUpdate",
		})
		use({ "nvim-treesitter/nvim-treesitter-textobjects" })
		use("JoosepAlviste/nvim-ts-context-commentstring")

		-- lsp
		use("neovim/nvim-lspconfig") -- enable LSP
		use("williamboman/nvim-lsp-installer") -- simple to use language server installer
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
		-- bufferline
		use({ "akinsho/bufferline.nvim", requires = "kyazdani42/nvim-web-devicons" })

		-- git
		use("lewis6991/gitsigns.nvim")
		use("tpope/vim-fugitive")
		use("sindrets/diffview.nvim")
		use("akinsho/git-conflict.nvim")

		-- programming languages
		use("rescript-lang/vim-rescript")
		use("jose-elias-alvarez/nvim-lsp-ts-utils")
		use("simrat39/rust-tools.nvim")
		use("ziglang/zig.vim")

		-- finder
		use("nvim-telescope/telescope.nvim")
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
