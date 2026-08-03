-- MoonBit editor integration is owned by moonbit-community/moonbit.nvim
-- (see lua/plugins/moonbit.lua): it handles filetype detection, the native
-- `moon-lsp` (OCaml) language server, treesitter parser install, mooncakes
-- completion and jsonls schemas.
--
-- This module now only contributes the `moon fmt` conform formatter, which
-- moonbit.nvim does not provide.

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
	formatter = {
		moonbit = { "moon_fmt" },
	},
	formatter_setup = function(conform)
		local util = require("conform.util")

		conform.formatters.moon_fmt = {
			command = moon_cmd(),
			args = { "fmt", "$FILENAME" },
			cwd = util.root_file({ "moon.mod", "moon.mod.json", "moon.work", "moon.work.json" }),
			stdin = false,
		}
	end,
}
