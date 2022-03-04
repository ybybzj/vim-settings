-- zen mode --
require("zen-mode").setup({})
require("twilight").setup()


-- smooth scroll --
require("neoscroll").setup()
local t = {}
t["<C-u>"] = { "scroll", { "-vim.wo.scroll", "true", "150" } }
t["<C-d>"] = { "scroll", { "vim.wo.scroll", "true", "100" } }
t["<C-b>"] = { "scroll", { "-vim.api.nvim_win_get_height(0)", "true", "150" } }
t["<C-f>"] = { "scroll", { "vim.api.nvim_win_get_height(0)", "true", "150" } }
require("neoscroll.config").set_mappings(t)
