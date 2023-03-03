local previewers = require("telescope.previewers")
local telescope_builtin = require("telescope.builtin")
local spectre = require("spectre")
local spectre_utils = require("spectre.utils")
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
		if not search or #search == 0 then
			search = vim.fn.expand("<cword>")
		end

		last_search_string = search

		opts.search = search
		telescope_builtin.grep_string(opts)
	else
		if not search or #search == 0 then
			search = vim.fn.expand("<cword>")
		end
		vim.ui.input({ prompt = "Grep > ", default = search }, function(input)
			if input and #input > 0 then
				opts.search = input
				last_search_string = input
				telescope_builtin.grep_string(opts)
			end
		end)
	end
end

-- install "git-delta" to use git diff view
M.grep_last = function(opts)
	opts = opts or {}
	opts.continue_last_search = true
	return M.grep_word(opts)
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
				"delta.side-by-side=false",
				"show",
				entry.value .. "^!",
				"--",
				entry.current_file,
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
				"delta.side-by-side=false",
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

M.search_and_replace = function(opts)
	opts = opts or {}
	if opts.select_word then
		opts.search_text = "\\b" .. vim.fn.expand("<cword>") .. "\\b"
	else
		opts.search_text = spectre_utils.get_visual_selection()
	end
	spectre.open(opts)
end

return M
