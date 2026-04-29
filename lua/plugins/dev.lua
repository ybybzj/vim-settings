return {
	-- minimap
	{
		"echasnovski/mini.map",
		lazy = true,
		version = false,
		config = function()
			local minimap = require("mini.map")
			local hunk_focus = require("config.git_hunk_focus")

			local function get_minimap_window()
				local current = minimap.current
				local win_id = current and current.win_data and current.win_data[vim.api.nvim_get_current_tabpage()]
				if win_id and vim.api.nvim_win_is_valid(win_id) then
					return win_id
				end
			end

			local function get_minimap_bounds(win_id)
				local config = vim.api.nvim_win_get_config(win_id)
				local width = config.width or vim.api.nvim_win_get_width(win_id)
				local height = config.height or vim.api.nvim_win_get_height(win_id)
				local row = math.floor((config.row or 0) + 0.5) + 1
				local col = math.floor((config.col or 0) + 0.5) + 1

				if config.anchor == "NE" or config.anchor == "SE" then
					col = col - width
				end

				if config.anchor == "SW" or config.anchor == "SE" then
					row = row - height
				end

				return row, col, height, width
			end

			local function find_source_window(source_buf)
				local current_win = vim.api.nvim_get_current_win()
				if vim.api.nvim_win_get_config(current_win).relative == "" and vim.api.nvim_win_get_buf(current_win) == source_buf then
					return current_win
				end

				for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
					if vim.api.nvim_win_get_config(win_id).relative == "" and vim.api.nvim_win_get_buf(win_id) == source_buf then
						return win_id
					end
				end
			end

			local function forward_left_mouse()
				local key = vim.api.nvim_replace_termcodes("<LeftMouse>", true, false, true)
				vim.api.nvim_feedkeys(key, "n", false)
			end

			local function jump_from_minimap_click()
				local win_id = get_minimap_window()
				if not win_id then
					forward_left_mouse()
					return
				end

				local mouse = vim.fn.getmousepos()
				local top, left, height, width = get_minimap_bounds(win_id)
				local inside_map = mouse.screenrow >= top
					and mouse.screenrow < top + height
					and mouse.screencol >= left
					and mouse.screencol < left + width

				if not inside_map then
					forward_left_mouse()
					return
				end

				local source_buf = minimap.current and minimap.current.buf_data and minimap.current.buf_data.source
				if not source_buf or not vim.api.nvim_buf_is_valid(source_buf) then
					return
				end

				local source_win = find_source_window(source_buf)
				if not source_win then
					return
				end

				-- Handle the click ourselves instead of relying on MiniMap's focus +
				-- CursorMoved sequence. That sequence races with mouse focus in floating
				-- windows and can pass clicks through to the covered source buffer.
				local map_buf = minimap.current.buf_data.map
				local map_rows = math.max(vim.api.nvim_buf_line_count(map_buf), 1)
				local source_rows = math.max(vim.api.nvim_buf_line_count(source_buf), 1)
				local map_line = math.min(math.max(mouse.screenrow - top + 1, 1), map_rows)
				local encode = minimap.current.opts.symbols.encode
				local resolution_row = encode and encode.resolution and encode.resolution.row or 1
				local rescaled_rows = math.min(source_rows, height * resolution_row)
				local coefficient = rescaled_rows / source_rows
				local source_line = math.min(
					math.max(math.ceil(((map_line - 1) * resolution_row) / coefficient) + 1, 1),
					source_rows
				)

				vim.api.nvim_set_current_win(source_win)
				vim.api.nvim_win_set_cursor(source_win, { source_line, 0 })
				vim.api.nvim_win_call(source_win, function()
					vim.cmd("normal! zvzz")
				end)
			end

			minimap.setup({
				integrations = {
					minimap.gen_integration.builtin_search(),
					minimap.gen_integration.gitsigns(),
					minimap.gen_integration.diagnostic(),
					hunk_focus.minimap_integration(),
				},
				symbols = {
					encode = minimap.gen_encode_symbols.dot("3x2"),
				},
				window = {
					focusable = true,
					show_integration_count = false,
				},
			})

			vim.keymap.set("n", "<LeftMouse>", jump_from_minimap_click, {
				desc = "Jump from minimap click",
				silent = true,
			})

			vim.api.nvim_create_autocmd("FileType", {
				group = vim.api.nvim_create_augroup("MiniMapMouseJump", { clear = true }),
				pattern = "minimap",
				callback = function(args)
					vim.keymap.set("n", "<LeftMouse>", jump_from_minimap_click, {
						buffer = args.buf,
						desc = "Jump from minimap",
						silent = true,
					})
				end,
			})
		end,
		keys = {
			{ "<leader>m", "<cmd>lua MiniMap.toggle()<cr>", desc = "Toggle MiniMap" },
		},
	},
	-- autopairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
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
		event = { "BufReadPost", "BufNewFile" },
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
		opts = {
			modes = {
				search = {
					enabled = true,
				},
			},
		},
		keys = {
			{
				"s",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump({
						search = {
							mode = function(str)
								return "\\<" .. str
							end,
						},
					})
				end,
				desc = "Jump search word",
			},
			{
				"<space>jl",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump({
						search = { mode = "search", max_length = 0 },
						label = { after = { 0, 0 } },
						pattern = "^",
					})
				end,
				desc = "Jump to line",
			},
			{
				"<space>jw",
				mode = { "n", "x", "o" },
				function()
					require("flash").jump({
						pattern = ".", -- initialize pattern with any char
						search = {
							mode = function(pattern)
								-- remove leading dot
								if pattern:sub(1, 1) == "." then
									pattern = pattern:sub(2)
								end
								-- return word pattern and proper skip pattern
								return ([[\<%s\w*\>]]):format(pattern), ([[\<%s]]):format(pattern)
							end,
						},
						-- select the range
						jump = { pos = "range" },
					})
				end,
				desc = "Jump to line",
			},
			{
				"<space>jt",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter({
						jump = { pos = "start" },
					})
				end,
				desc = "Jump Treesitter node",
			},
			{
				"S",
				mode = { "n", "x", "o" },
				function()
					require("flash").treesitter()
				end,
				desc = "Jump Treesitter selection",
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
		event = "VeryLazy",
		config = function()
			require("nvim-surround").setup()
		end,
	},
	-- others
	{
		"tpope/vim-repeat",
		event = "VeryLazy",
	},
	{
		"2kabhishek/nerdy.nvim",
		dependencies = {
			"folke/snacks.nvim",
		},
		cmd = "Nerdy",
		config = function() end,
	},
}
