local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
	return
end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
	return
end

require("luasnip.loaders.from_vscode").lazy_load()

local check_backspace = function()
	local col = vim.fn.col(".") - 1
	return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

local has_words_before = function()
	if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
		return false
	end
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end

local kind_icons = {
	Text = "󰉿",
	Method = "m",
	Function = "󰊕",
	Constructor = "",
	Field = "",
	Variable = "",
	Class = "󰌗",
	Interface = "",
	Module = "󰕳",
	Property = "",
	Unit = "",
	Value = "󰎠",
	Enum = "",
	Keyword = "󰌋",
	Snippet = "",
	Color = "󰏘",
	File = "󰈙",
	Reference = "",
	Folder = "󰉋",
	EnumMember = "",
	Constant = "󰇽",
	Struct = "",
	Event = "",
	Operator = "󰆕",
	TypeParameter = "󰊄",
}
-- find more here: https://www.nerdfonts.com/cheat-sheet

local lspkind = require("lspkind")

cmp.setup({
	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
			luasnip.lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
		["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
		["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
		["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
		["<C-e>"] = cmp.mapping({
			i = cmp.mapping.abort(),
			c = cmp.mapping.close(),
		}),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = vim.schedule_wrap(function(fallback)
			if cmp.visible() and has_words_before() then
				cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
			else
				fallback()
			end
		end),

		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { "i", "s" }),
	}),
	formatting = {
		fields = { "abbr", "kind", "menu" },
		-- format = function(entry, vim_item)
		-- 	-- 	if entry.source.name == "copilot" then
		-- 	-- 		vim_item.kind = "[] Copilot"
		-- 	-- 		vim_item.kind_hl_group = "CmpItemKindCopilot"
		-- 	-- 		return vim_item
		-- 	-- 	end
		-- 	-- Kind icons
		-- 	vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
		-- 	-- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
		-- 	vim_item.menu = ({
		-- 		nvim_lsp = "[LSP]",
		-- 		copilot = "[Copilot]",
		-- 		luasnip = "[Snippet]",
		-- 		buffer = "[Buffer]",
		-- 		path = "[Path]",
		-- 	})[entry.source.name]
		-- 	return vim_item
		-- end,
		format = lspkind.cmp_format({
			mode = "symbol_text",
			show_labelDetails = true,
		}),
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp", priority = 7, max_item_count = 25 },

		{ name = "copilot", priority = 7 },
		{ name = "nvim_lua", priority = 7 },
		{ name = "buffer", priority = 7, keyword_length = 3 },
		{ name = "luasnip", priority = 6 }, -- For luasnip users.
		-- { name = "copilot", priority = 6 },
		{ name = "path", priority = 5 },
		{ name = "emoji", priority = 4 },
	}),

	confirm_opts = {
		behavior = cmp.ConfirmBehavior.Replace,
		select = false,
	},
	window = {
		documentation = cmp.config.window.bordered(),
	},
	experimental = {
		ghost_text = true,
		native_menu = false,
	},
	sorting = {
		priority_weight = 1.0,
		comparators = {
			-- compare.score_offset, -- not good at all
			cmp.config.compare.locality,
			cmp.config.compare.recently_used,
			cmp.config.compare.exact,
			cmp.config.compare.score, -- based on :  score = score + ((#sources - (source_index - 1)) * sorting.priority_weight)
			cmp.config.compare.offset,
			cmp.config.compare.order,
			-- cmp.config.compare.scopes, -- what?
			cmp.config.compare.sort_text,
			cmp.config.compare.kind,
			cmp.config.compare.length, -- useless
		},
	},
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = "buffer" },
	},
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline" },
	}),
})

vim.api.nvim_set_hl(0, "CmpItemKindCopilot", { fg = "#6CC644" })
