local telescope_builtin = require("telescope.builtin")
local utils = require("my.helpers")
local M = {}

local last_search_string
M.grep_word = function(opts)
	opts = utils.extends({
		word_match = "-w",
	}, opts)
	local search = opts.search

	if opts.continue_last_search then
		search = last_search_string
	end

	if not search or #search == 0 then
		search = vim.fn.expand("<cword>")
	end

	last_search_string = search

	opts.search = search
	telescope_builtin.grep_string(opts)
end

M.grep_last = function(opts)
	opts = opts or {}
	opts.continue_last_search = true
	return M.grep_word(opts)
end

return M
