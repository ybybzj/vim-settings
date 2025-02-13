local spectre = require("spectre")
local spectre_utils = require("spectre.utils")
local M = {}

local last_search_path
M.search_and_replace = function(opts)
	opts = opts or {}
	if opts.select_word then
		opts.search_text = vim.fn.expand("<cword>")
	else
		opts.search_text = spectre_utils.get_visual_selection()
	end

	local search_path = last_search_path
	if opts.continue_last_path then
		if search_path and #search_path > 0 then
			opts.search_paths = { search_path }
		end

		spectre.open(opts)
	else
		Snacks.input({ prompt = "Path > ", default = "" }, function(input)
			if input and #input > 0 then
				opts.search_paths = { input }
			end

			last_search_path = input
			spectre.open(opts)
		end)
	end

	-- change the write autocmd to 'BufWritePost'
	local augroup = vim.api.nvim_create_augroup("spectre_panel_write", { clear = true })
	vim.api.nvim_clear_autocmds({ pattern = "*", group = augroup })
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = augroup,
		pattern = "*",
		callback = spectre.on_write,
		desc = "spectre write autocmd",
	})
end

return M
