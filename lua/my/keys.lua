local map = require("my.shared").mapkey
local cmd = vim.cmd

------------------key mappings -----------------------
vim.g.mapleader = ","
map("", "<leader>l", ":NERDTreeToggle<cr>")
map("", "<leader>cd", ":cd %:p:h<cr>")
cmd([[
cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
]])

map("n", "<M-s>", "<Esc>:wa<cr><Esc>")
map("i", "<M-s>", "<Esc>:wa<cr>")
map("", "<M-q>", "<Esc>:q<cr>")
map("", "<M-Q>", "<Esc>:qa<cr>")
map("", "<leader>vr", ":Reload<cr>")
map("n", "<leader>ve", ":e ~/.config/nvim/<cr>")
map("n", "<leader>i3", ":e ~/.i3/config<cr>")
map("n", "<cr>", ":noh<cr><cr>")
map("n", "<Up>", "gk")
map("n", "<Down>", "gj")
------- fold --------------
map("n", "<leader>zc", "ziza")
------- copy --------------
map("v", "<M-c>", '"+y<cr>')
map("n", "<M-v>", '"+P<cr>')
map("v", "<M-v>", '"+P<cr>')

-------zen mode -----------
map("n", "<leader>zm", ":ZenMode<cr>")
map("n", "<leader>tw", ":Twilight<cr>")

-- smooth scroll --
local t = {}
t["<C-u>"] = { "scroll", { "-vim.wo.scroll", "true", "150" } }
t["<C-d>"] = { "scroll", { "vim.wo.scroll", "true", "100" } }
t["<C-b>"] = { "scroll", { "-vim.api.nvim_win_get_height(0)", "true", "150" } }
t["<C-f>"] = { "scroll", { "vim.api.nvim_win_get_height(0)", "true", "150" } }
require("neoscroll.config").set_mappings(t)

-- hopper setting --
map("n", "$", ":HopWord<cr>")
map("n", "<leader>hL", ":HopLine<cr>")
map("n", "<leader>hl", ":HopChar1<cr>")
-- minimap --
map("n", "<leader>m", ":MinimapToggle<cr>")

-- lazygit --
map("n", "<leader>gg", "<cmd>lua _lazygit_toggle()<CR>", { silent = true })
