-- debugger --
function _G.dump(...)
	local objects = vim.tbl_map(vim.inspect, { ... })
	print(unpack(objects))
	return ...
end

require("my.opts")
require("my.plugins")
require("my.utils")
require("my.keys")
require("my.theme")
require("my.statusline")
require("my.tree")
require("my.cmp")
require("my.terminal")
require("my.treesitter")
require("my.lsp")
require("my.dev")
require("my.git")
require("my.comment")
