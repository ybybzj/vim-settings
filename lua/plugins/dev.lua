return {
	-- minimap
	{
		"echasnovski/mini.map",
		version = false,
		config = function()
			local minimap = require("mini.map")
			minimap.setup({
				integrations = {
					minimap.gen_integration.builtin_search(),
					minimap.gen_integration.gitsigns(),
					minimap.gen_integration.diagnostic(),
				},
				symbols = {
					encode = minimap.gen_encode_symbols.dot("3x2"),
				},
			})
		end,
		keys = {
			{ "<leader>m", "<cmd>lua MiniMap.toggle()<cr>", desc = "Toggle MiniMap" },
		},
	},
	-- autopairs
	{
		"windwp/nvim-autopairs",
		config = function()
			local npairs = require("nvim-autopairs")
			npairs.setup()

			local Rule = require("nvim-autopairs.rule")
			npairs.add_rule(Rule("|", "|", "zig"))
		end,
	},
	-- folding
	{
		"kevinhwang91/nvim-ufo",
		dependencies = "kevinhwang91/promise-async",
		init = function()
			vim.o.foldcolumn = "1" -- '0' is not bad
			vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
			vim.o.foldlevelstart = 99
			vim.o.foldenable = true
		end,
		config = function()
			local ufo = require("ufo")

			vim.keymap.set("n", "zR", ufo.openAllFolds)
			vim.keymap.set("n", "zM", ufo.closeAllFolds)
			vim.keymap.set("n", "zr", ufo.openFoldsExceptKinds)
			vim.keymap.set("n", "zm", function()
				ufo.closeFoldsWith(1)
			end) -- closeAllFolds == closeFoldsWith(0)

			local ftMap = {
				vim = "indent",
				python = { "indent" },
				git = "",
			}

			local function customizeSelector(bufnr)
				local function handleFallbackException(err, providerName)
					if type(err) == "string" and err:match("UfoFallbackException") then
						return require("ufo").getFolds(bufnr, providerName)
					else
						return require("promise").reject(err)
					end
				end

				return require("ufo")
					.getFolds(bufnr, "lsp")
					:catch(function(err)
						return handleFallbackException(err, "treesitter")
					end)
					:catch(function(err)
						return handleFallbackException(err, "indent")
					end)
			end

			ufo.setup({
				provider_selector = function(bufnr, filetype, buftype)
					return ftMap[filetype] or customizeSelector
				end,
			})
		end,
	},
	-- quickfix list
	{
		"kevinhwang91/nvim-bqf",
		ft = "qf",
		config = function()
			local cmd = vim.cmd
			local bqf = require("bqf")

			cmd([[
        hi BqfPreviewBorder guifg=#50a14f ctermfg=71
        hi link BqfPreviewRange Search
      ]])

			bqf.setup({
				auto_enable = true,
				auto_resize_height = true, -- highly recommended enable
				preview = {
					win_height = 12,
					win_vheight = 12,
					delay_syntax = 80,
					border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" },
					should_preview_cb = function(bufnr, qwinid)
						local ret = true
						local bufname = vim.api.nvim_buf_get_name(bufnr)
						local fsize = vim.fn.getfsize(bufname)
						if fsize > 100 * 1024 then
							-- skip file size greater than 100k
							ret = false
						elseif bufname:match("^fugitive://") then
							-- skip fugitive buffer
							ret = false
						end
						return ret
					end,
				},
				-- make `drop` and `tab drop` to become preferred
				func_map = {
					drop = "o",
					openc = "O",
					split = "<C-s>",
					tabdrop = "<C-t>",
					tabc = "",
					ptogglemode = "z,",
					del = "<C-x>",
				},
				filter = {
					fzf = {
						action_for = { ["ctrl-s"] = "split", ["ctrl-t"] = "tab drop" },
						extra_opts = { "--bind", "ctrl-o:toggle-all", "--prompt", "> " },
					},
				},
			})
		end,
		keys = {
			{ "<space>q", "<cmd>copen<cr>", desc = "Open quickfix list" },
		},
	},

	-- hop or jump
	{
		"folke/flash.nvim",
		event = "VeryLazy",
		opts = {},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump()
				end,
				desc = "Flash",
			},
			{
				"<c-s>",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Flash Treesitter",
			},
			{
				"r",
				mode = "o",
				function()
					require("flash").remote()
				end,
				desc = "Remote Flash",
			},
			{
				"R",
				mode = { "o", "x" },
				function()
					require("flash").treesitter_search()
				end,
				desc = "Treesitter Search",
			},
		},
	},
	-- surround
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
	-- others
	"tpope/vim-repeat",
	{
		"2kabhishek/nerdy.nvim",
		dependencies = {
			"stevearc/dressing.nvim",
		},
		cmd = "Nerdy",
		config = function() end,
	},
}
