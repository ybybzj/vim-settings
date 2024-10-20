local status_ok, ts = pcall(require, "nvim-treesitter.configs")
if not status_ok then
	return
end

local tspath = vim.fn.stdpath("data") .. "/treesitter/parsers"
vim.opt.rtp:prepend(tspath)

ts.setup({
	parser_install_dir = tspath,
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
		-- "rescript",
	},
	sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
	highlight = { enable = true },
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "gnn",
			node_incremental = "grn",
			scope_incremental = "grc",
			node_decremental = "grm",
		},
	},
	matchup = { enable = true },
	autopairs = { enable = true },
	textobjects = {
		select = {
			enable = true,

			-- Automatically jump forward to textobj, similar to targets.vim
			lookahead = true,

			keymaps = {
				-- You can use the capture groups defined in textobjects.scm
				["af"] = "@function.outer",
				["if"] = "@function.inner",
				["ac"] = "@call.outer",
				["ic"] = "@call.inner",
				["ib"] = "@block.inner",
				["ab"] = "@block.outer",
				["ip"] = "@parameter.inner",
				["ap"] = "@parameter.outer",

				-- Or you can define your own textobjects like this
				-- ["iF"] = {
				-- 	python = "(function_definition) @function",
				-- 	cpp = "(function_definition) @function",
				-- 	c = "(function_definition) @function",
				-- 	java = "(method_declaration) @function",
				-- },
			},
		},
		move = {
			enable = true,
			set_jumps = true, -- whether to set jumps in the jumplist
			goto_next_start = {
				["]m"] = "@function.outer",
				["]]"] = "@class.outer",
			},
			goto_next_end = {
				["]M"] = "@function.outer",
				["]["] = "@class.outer",
			},
			goto_previous_start = {
				["[m"] = "@function.outer",
				["[["] = "@class.outer",
			},
			goto_previous_end = {
				["[M"] = "@function.outer",
				["[]"] = "@class.outer",
			},
		},
	},
})

-- folding
local status_ok, ufo = pcall(require, "ufo")
if not status_ok then
	return
end

vim.o.foldcolumn = "1" -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true

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
