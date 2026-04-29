vim.filetype.add({
	extension = {
		mbt = "moonbit",
		mbti = "moonbit",
		mbtx = "moonbit",
	},
	filename = {
		["moon.pkg"] = "moonbit",
	},
	pattern = {
		[".*%.mbt%.md"] = "moonbit",
	},
})

local function moonbit_lsp_cmd()
	local moon_home = vim.env.MOON_HOME or (vim.env.HOME and (vim.env.HOME .. "/.moon")) or "~/.moon"
	local toolchain_lsp = vim.fn.resolve(moon_home .. "/bin/moonbit-lsp")
	local bundled_lsp = vim.fn.resolve(moon_home .. "/bin/lsp-server.js")

	if vim.fn.executable(toolchain_lsp) == 1 then
		return { toolchain_lsp }
	end

	if vim.fn.executable(bundled_lsp) == 1 then
		return { bundled_lsp }
	end

	if vim.fn.filereadable(bundled_lsp) == 1 and vim.fn.executable("node") == 1 then
		return { "node", bundled_lsp }
	end

	return { "moonbit-lsp" }
end

local function moon_cmd()
	local path_moon = vim.fn.exepath("moon")
	if path_moon ~= "" then
		return path_moon
	end

	local moon_home = vim.env.MOON_HOME or (vim.env.HOME and (vim.env.HOME .. "/.moon")) or "~/.moon"
	local toolchain_moon = vim.fn.resolve(moon_home .. "/bin/moon")
	if vim.fn.executable(toolchain_moon) == 1 then
		return toolchain_moon
	end

	return "moon"
end

return {
	-- MoonBit is not currently registered by nvim-lspconfig/mason-lspconfig, so
	-- define and enable the server directly while excluding it from Mason's
	-- ensure_installed list.
	server_name = "moonbit-lsp",
	mason = false,
	formatter = {
		moonbit = { "moon_fmt" },
	},
	formatter_setup = function(conform)
		local util = require("conform.util")

		conform.formatters.moon_fmt = {
			command = moon_cmd(),
			args = { "fmt", "$FILENAME" },
			cwd = util.root_file({ "moon.mod.json", "moon.work", "moon.work.json" }),
			stdin = false,
		}
	end,
	lspconfig = function(_, opts)
		opts.cmd = moonbit_lsp_cmd()
		opts.filetypes = { "moonbit" }
		opts.root_markers = { "moon.mod.json", "moon.work", "moon.work.json" }
		opts.workspace_required = true

		vim.lsp.config("moonbit-lsp", opts)
		vim.lsp.enable("moonbit-lsp")
	end,
}
