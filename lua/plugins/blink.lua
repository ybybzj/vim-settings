local kind_icons = {
	codicons = {
		Text = "",
		Method = "",
		Function = "",
		Constructor = "",
		Field = "",
		Variable = "",
		Class = "",
		Interface = "",
		Module = "",
		Property = "",
		Unit = "",
		Value = "",
		Enum = "",
		Keyword = "",
		Snippet = "",
		Color = "",
		File = "",
		Reference = "",
		Folder = "",
		EnumMember = "",
		Constant = "",
		Struct = "",
		Event = "",
		Operator = "",
		TypeParameter = "",
	},

	default = {
		Text = "󰉿",
		Method = "󰊕",
		Function = "󰊕",
		Constructor = "󰒓",

		Field = "󰜢",
		Variable = "󰆦",
		Property = "󰖷",

		Class = "󱡠",
		Interface = "󱡠",
		Struct = "󱡠",
		Module = "󰅩",

		Unit = "󰪚",
		Value = "󰦨",
		Enum = "󰦨",
		EnumMember = "󰦨",

		Keyword = "󰻾",
		Constant = "󰏿",

		Snippet = "󱄽",
		Color = "󰏘",
		File = "󰈔",
		Reference = "󰬲",
		Folder = "󰉋",
		Event = "󱐋",
		Operator = "󰪚",
		TypeParameter = "󰬛",
	},
}
return {
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
			"folke/lazydev.nvim",
		},

		-- use a release tag to download pre-built binaries
		version = "*",
		opts = {
			-- 'default' for mappings similar to built-in completion
			-- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
			-- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
			-- See the full "keymap" documentation for information on defining your own keymap.
			keymap = { preset = "enter" },

			appearance = {
				-- Sets the fallback highlight groups to nvim-cmp's highlight groups
				-- Useful for when your theme doesn't support blink.cmp
				-- Will be removed in a future release
				use_nvim_cmp_as_default = true,
				-- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
				-- Adjusts spacing to ensure icons are aligned
				nerd_font_variant = "mono",
				kind_icons = kind_icons.codicons,
			},

			completion = {
				list = {
					selection = {
						preselect = function(ctx)
							return ctx.mode ~= "cmdline"
						end,
						auto_insert = function(ctx)
							return ctx.mode ~= "cmdline"
						end,
					},
				},
				menu = {
					border = "rounded",
					-- Don't show completion menu automatically when searching
					auto_show = function(ctx)
						return ctx.mode ~= "cmdline" or not vim.tbl_contains({ "/", "?" }, vim.fn.getcmdtype())
					end,
				},
				documentation = { window = { border = "rounded" } },
			},

			-- Default list of enabled providers defined so that you can extend it
			-- elsewhere in your config, without redefining it, due to `opts_extend`
			sources = {
				default = function()
					local success, node = pcall(vim.treesitter.get_node)
					if vim.bo.filetype == "lua" then
						return { "lsp", "lazydev", "path" }
					elseif
						success
						and node
						and vim.tbl_contains({ "comment", "line_comment", "block_comment" }, node:type())
					then
						return { "buffer", "path" }
					else
						return { "lsp", "snippets", "buffer", "path" }
					end
				end,
				providers = {
					lsp = {
						name = "LSP",
						module = "blink.cmp.sources.lsp",
						score_offset = 10,
					},
					buffer = {
						opts = {
							-- get all buffers, even ones like neo-tree
							-- get_bufnrs = vim.api.nvim_list_bufs
							-- or (recommended) filter to only "normal" buffers
							get_bufnrs = function()
								return vim.tbl_filter(function(bufnr)
									return vim.bo[bufnr].buftype == ""
								end, vim.api.nvim_list_bufs())
							end,
						},
					},
					path = {
						opts = {
							get_cwd = function(_)
								return vim.fn.getcwd()
							end,
						},
					},
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						-- make lazydev completions top priority (see `:h blink.cmp`)
					},
					cmdline = {
						name = "cmdline",
						module = "blink.compat.source",
						score_offset = -3,
					},
				},
			},
			signature = { enabled = true, window = { border = "rounded" } },
		},
	},
}
