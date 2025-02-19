local handlers = require("lsp.utils.handlers")
local default_keymaps = require("lsp.utils.keymaps")

local utils = require("utils")
local function load()
	local lsp_dir = vim.fn.stdpath("config") .. "/lua/lsp"
	local settings = utils.load_lua_modules(lsp_dir, "lsp")
	local function checkEnable(_, m)
		return m["enable"] ~= false
	end

	local config = function(key, mode)
		local setting_maps = utils.selectKeyFromTbls(key, settings, checkEnable)
		local ret = {}
		for _, v in pairs(setting_maps) do
			if mode == "merge" then
				ret = vim.tbl_deep_extend("force", ret, v)
			else
				table.insert(ret, v)
			end
		end
		return ret
	end

	return {
		server_names = function()
			return config("server_name")
		end,
		lspconfig = function(lspconfig)
			local lspcfgs = config({ "lspconfig", "opts", "server_name", "keys" })
			for _, cfg in ipairs(lspcfgs) do
				local keymaps = utils.extends(default_keymaps, cfg["keys"])

				local default_opts = {
					on_attach = function(client, bufnr)
						handlers.lsp_keymaps(client, bufnr, keymaps)
						handlers.lsp_highlight_document(client, bufnr)
						handlers.lsp_codelens(client, bufnr)
					end,
					capabilities = handlers.make_client_capabilities(),
				}
				local opts = utils.extends(default_opts, cfg["opts"] or {})

				local setup = cfg["lspconfig"]
				if type(setup) == "function" then
					setup(lspconfig, opts)
				else
					local server_name = cfg["server_name"]
					lspconfig[server_name].setup(opts)
				end
			end
		end,
		formatters = function()
			return config("formatter", "merge")
		end,
		formatters_setup = function(conform)
			local setups = config("formatter_setup")
			for _name, formatter_setup in ipairs(setups) do
				formatter_setup(conform)
			end
		end,
		linters = function()
			return config("linter", "merge")
		end,
		dependencies = function()
			return config("dependencies")
		end,
	}
end

return {
	load = load,
}
