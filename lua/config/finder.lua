local M = {}

local staticTitle = "Find And Replace"

---@class FindAndReplaceOptions
---@field public search string?
---@field public paths string?
---@field public instanceName string

---@param opts FindAndReplaceOptions
M.find_and_replace = function(opts)
	local far = require("grug-far")

	local hasInstance = far.has_instance(opts.instanceName)

	local prefills = opts.paths and { paths = opts.paths } or {}
	local search = opts.search or far.get_current_visual_selection(true) or vim.fn.expand("<cword>")
	if search then
		prefills.search = search
	end

	if hasInstance then
		far.update_instance_prefills(opts.instanceName, prefills, false)
		if not far.is_instance_open(opts.instanceName) then
			far.open_instance(opts.instanceName)
		end
	else
		far.open({
			instanceName = opts.instanceName,
			staticTitle = "Find and Replace",
			prefills = prefills,
		})
	end
end
return M
