local M = {}

M.extends = function(target, dict)
	target = target or {}
	local result = target
	if dict then
		result = vim.tbl_extend("force", target, dict)
	end
	return result
end

-- https://stackoverflow.com/a/4991602
local file_exists = function(name)
	local f = io.open(name, "r")
	if f ~= nil then
		io.close(f)
		return true
	else
		return false
	end
end

-- https://stackoverflow.com/a/20460403
local findLast = function(haystack, needle)
	local i = haystack:match(".*" .. needle .. "()")
	if i == nil then
		return nil
	else
		return i - 1
	end
end

local parent_dir = function(dir)
	return dir:sub(1, findLast(dir, "/") - 1)
end

local term_pattern = parent_dir(os.getenv("HOME"))

local find_root = function(start_path, rooter_pattern)
	rooter_pattern = rooter_pattern or { ".git" }
	if not (start_path:find(term_pattern) == 1) then
		return nil
	end

	local possible_root_dir = start_path
	local found = false

	while start_path ~= term_pattern do
		for _, dir in ipairs(rooter_pattern) do
			if file_exists(start_path .. "/" .. dir) then
				found = true
				possible_root_dir = start_path

				if not vim.g.outermost_root then
					return possible_root_dir
				end
				break
			end
		end

		start_path = parent_dir(start_path)
	end

	if found then
		return possible_root_dir
	end
end

local __root_dir = function(prefix, cwd, rooter_pattern)
	local root_dir = find_root(prefix, rooter_pattern)
	if root_dir then
		return root_dir
	else
		return cwd
	end
end

M.cd_root = function(prefix, cwd, rooter_pattern)
	local path = __root_dir(prefix, cwd, rooter_pattern)
	vim.cmd("cd " .. path)
end

M.find_root = find_root

return M
