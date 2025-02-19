local map = vim.keymap.set
local cmd = vim.cmd

-- leader key
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- source code
map("n", "<leader><leader>x", "<cmd>source %<cr>")
map("n", "<leader>x", ":.lua<cr>")
map("v", "<leader>x", ":lua<cr>")

map("", "<leader>q", ":copen<cr>")
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
map("", "<leader>ct", "<Esc>:tabclose<cr>")
map("n", "<cr>", ":noh<cr><cr>")
map("n", "<Up>", "gk")
map("n", "<Down>", "gj")
------- copy --------------
map("v", "<M-c>", '"+y<cr>')
map("n", "<M-v>", '"+P<cr>')
map("v", "<M-v>", '"+P<cr>')

-------- move line ---------
map("n", "<M-Up>", ":m .-2<CR>==", { noremap = true, silent = true })
map("n", "<M-Down>", ":m .+1<CR>==", { noremap = true, silent = true })

-- Move selected lines up/down in visual mode
map("v", "<M-Up>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
map("v", "<M-Down>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
