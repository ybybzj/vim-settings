local previewers = require("telescope.previewers")
local telescope_builtin = require("telescope.builtin")
local utils = require("my.helpers")
local M = {}

M.grep_word = function(opts)
	opts = utils.extends({
		word_match = "-w",
	}, opts)
	local search = opts.search

	if not search or #search == 0 then
		search = vim.fn.expand("<cword>")
	end

	opts.search = search
	telescope_builtin.grep_string(opts)
end

-- git --
M.git_bcommits = function(opts)
	opts = opts or {}
	opts.previewer = previewers.new_termopen_previewer({
		get_command = function(entry)
			return {
				"git",
				"-c",
				"core.pager=delta",
				"-c",
				"delta.pager=less -R",
				"-c",
				"delta.features=side-by-side",
				"show",
				entry.value,
			}
		end,
	})

	telescope_builtin.git_bcommits(opts)
end

M.git_status = function(opts)
	opts = opts or {}
	opts.previewer = previewers.new_termopen_previewer({
		get_command = function(entry)
			if entry.status == "D " then
				return { "git", "show", "HEAD:" .. entry.value }
			elseif entry.status == "??" then
				return { "bat", "--style=plain", entry.value }
			end
			return {
				"git",
				"-c",
				"core.pager=delta",
				"-c",
				"delta.pager=less -R",
				"-c",
				"delta.features=side-by-side",
				"diff",
				entry.value,
			}
		end,
	})

	-- Use icons that resemble the `git status` command line.
	opts.git_icons = {
		added = "A",
		changed = "M",
		copied = "C",
		deleted = "-",
		renamed = "R",
		unmerged = "U",
		untracked = "?",
	}

	telescope_builtin.git_status(opts)
end

return M
