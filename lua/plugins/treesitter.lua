return {
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
		build = ":TSUpdate",
		config = function()
			local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
			parser_config.moonbit = {
				install_info = {
					url = "https://github.com/moonbitlang/tree-sitter-moonbit",
					files = { "src/parser.c", "src/scanner.c" },
					branch = "main",
				},
				filetype = "moonbit",
			}

			local configs = require("nvim-treesitter.configs")

			configs.setup({
				ensure_installed = {
					"c",
					"lua",
					"rust",
					"zig",
					"javascript",
					"typescript",
					"go",
					"css",
					"html",
					"tsx",
					"toml",
					"yaml",
					"markdown",
					"markdown_inline",
					"latex",
					"moonbit",
				},
				sync_install = false,
				highlight = { enable = true },
				indent = { enable = true },

				incremental_selection = {
					enable = true,
					keymaps = {
						init_selection = "gv",
						node_incremental = "]",
						scope_incremental = "}",
						node_decremental = "[",
					},
				},
				matchup = { enable = true },
				autopairs = { enable = true },
				textobjects = {
					select = {
						enabled = false,
					},
					-- select = {
					-- 	enable = true,
					--
					-- 	-- Automatically jump forward to textobj, similar to targets.vim
					-- 	lookahead = true,
					--
					-- 	keymaps = {
					-- 		-- You can use the capture groups defined in textobjects.scm
					-- 		["af"] = "@function.outer",
					-- 		["if"] = "@function.inner",
					-- 		["ac"] = "@call.outer",
					-- 		["ic"] = "@call.inner",
					-- 		["ib"] = "@block.inner",
					-- 		["ab"] = "@block.outer",
					-- 		["ip"] = "@parameter.inner",
					-- 		["ap"] = "@parameter.outer",
					--
					-- 		-- Or you can define your own textobjects like this
					-- 		-- ["iF"] = {
					-- 		-- 	python = "(function_definition) @function",
					-- 		-- 	cpp = "(function_definition) @function",
					-- 		-- 	c = "(function_definition) @function",
					-- 		-- 	java = "(method_declaration) @function",
					-- 		-- },
					-- 	},
					-- },
					move = {
						enable = true,
						set_jumps = true, -- whether to set jumps in the jumplist
						goto_next_start = {
							["]B"] = "@block.outer",
							["]M"] = "@function.outer",
							["]["] = "@class.outer",
						},
						goto_next_end = {
							["]b"] = "@block.outer",
							["]m"] = "@function.outer",
							["]]"] = "@class.outer",
							["]c"] = "@call.outer",
						},
						goto_previous_start = {
							["[b"] = "@block.inner",
							["[m"] = "@function.inner",
							["[["] = "@class.inner",
						},
						goto_previous_end = {
							["[B"] = "@block.outer",
							["[M"] = "@function.outer",
							["[]"] = "@class.outer",
							["[c"] = "@call.outer",
						},
					},
				},
			})

			-- nvim-treesitter's archived master branch still registers a few query
			-- directive handlers with the pre-0.12 capture shape. Neovim 0.12 passes
			-- captures as lists of nodes, so normalize here to keep markdown
			-- injections working in files and LSP hover floats without a full migration
			-- to nvim-treesitter's new main-branch API.
			local query = vim.treesitter.query
			local directive_opts = { force = true }

			local html_script_type_languages = {
				importmap = "json",
				module = "javascript",
				["application/ecmascript"] = "javascript",
				["text/ecmascript"] = "javascript",
			}

			local language_aliases = {
				ex = "elixir",
				pl = "perl",
				sh = "bash",
				uxn = "uxntal",
				ts = "typescript",
			}

			local function first_node(match, capture_id)
				local node = match[capture_id]
				if type(node) == "table" then
					node = node[1]
				end
				return node
			end

			local function parser_from_markdown_info(injection_alias)
				local filetype = vim.filetype.match({ filename = "a." .. injection_alias })
				return filetype or language_aliases[injection_alias] or injection_alias
			end

			query.add_directive("set-lang-from-mimetype!", function(match, _, source, pred, metadata)
				local node = first_node(match, pred[2])
				if not node then
					return
				end

				local type_attr_value = vim.treesitter.get_node_text(node, source)
				local configured = html_script_type_languages[type_attr_value]
				if configured then
					metadata["injection.language"] = configured
				else
					local parts = vim.split(type_attr_value, "/", {})
					metadata["injection.language"] = parts[#parts]
				end
			end, directive_opts)

			query.add_directive("set-lang-from-info-string!", function(match, _, source, pred, metadata)
				local node = first_node(match, pred[2])
				if not node then
					return
				end

				local injection_alias = vim.treesitter.get_node_text(node, source):lower()
				metadata["injection.language"] = parser_from_markdown_info(injection_alias)
			end, directive_opts)

			query.add_directive("downcase!", function(match, _, source, pred, metadata)
				local id = pred[2]
				local node = first_node(match, id)
				if not node then
					return
				end

				local text = vim.treesitter.get_node_text(node, source, { metadata = metadata[id] }) or ""
				metadata[id] = metadata[id] or {}
				metadata[id].text = string.lower(text)
			end, directive_opts)
		end,
	},
	{
		"echasnovski/mini.ai",
		version = "*",
		opts = {},
		config = function()
			local mini_ai = require("mini.ai")
			local spec_treesitter = mini_ai.gen_spec.treesitter
			mini_ai.setup({
				custom_textobjects = {
					f = spec_treesitter({ a = "@function.outer", i = "@function.inner" }),
					c = spec_treesitter({
						a = { "@call.outer" },
						i = { "@call.inner" },
					}),
					a = spec_treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
				},
			})
		end,
	},
	"JoosepAlviste/nvim-ts-context-commentstring",
}
