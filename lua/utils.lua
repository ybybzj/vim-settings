local M = {}
local function load_lua_modules(directory, prefix)
	local lua_files = vim.fn.glob(directory .. "/*.lua", false, true)
	local modules = {}
	for _, file in ipairs(lua_files) do
		local module_name = vim.fn.fnamemodify(file, ":t:r")
		local module_path = (prefix and prefix .. "." or "") .. module_name
		local ok, module = pcall(require, module_path)
		if ok then
			if module_name == "lua_" then
				module_name = "lua"
			end
			modules[module_name] = module
		else
			print("Failed to load module: " .. module_path, module)
		end
	end
	return modules
end

local function selectKeyFromTbls(key, tbls, module_filter)
	local tables = {}
	if not key or key == "" then
		return tables
	end

	for name, module in pairs(tbls) do
		if module_filter and not module_filter(name, module) then
			goto continue
		end

		local t = type(key)
		if t == "string" then
			local value = module[key]
			if value then
				tables[name] = value
			end
		elseif t == "table" then
			local value = {}
			for _, tblk in ipairs(key) do
				local v = module[tblk]
				if v then
					value[tblk] = v
				end
			end
			tables[name] = value
		end

		::continue::
	end
	return tables
end

M.extends = function(source, target)
	return vim.tbl_deep_extend("force", source, target or {})
end
M.load_lua_modules = load_lua_modules
M.selectKeyFromTbls = selectKeyFromTbls

return M
