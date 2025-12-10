local map = vim.keymap.set

-- leader key
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- source code
map("n", "<leader><leader>x", "<cmd>source %<cr>", { desc = "Source current file" })
map("n", "<leader>x", ":.lua<cr>", { desc = "Execute current line as Lua" })
map("v", "<leader>x", ":lua<cr>", { desc = "Execute selection as Lua" })

map("n", "<leader>q", ":copen<cr>", { desc = "Open quickfix list" })
map("n", "<leader>cd", ":cd %:p:h<cr>", { desc = "Change to current file directory" })

-- File path shortcuts (cmdline)
vim.keymap.set("c", "%%", function()
	return vim.fn.fnameescape(vim.fn.expand("%:h")) .. "/"
end, { expr = true, desc = "Insert current file directory" })
map("n", "<leader>ew", ":e <C-r>=fnameescape(expand('%:h')).'/'<cr>", { desc = "Edit file in current directory" })
map("n", "<leader>es", ":sp <C-r>=fnameescape(expand('%:h')).'/'<cr>", { desc = "Split file in current directory" })
map("n", "<leader>ev", ":vsp <C-r>=fnameescape(expand('%:h')).'/'<cr>", { desc = "Vsplit file in current directory" })

-- Save and quit
map("n", "<M-s>", "<Esc>:wa<cr><Esc>", { desc = "Save all files" })
map("i", "<M-s>", "<Esc>:wa<cr>", { desc = "Save all files" })
map("n", "<M-q>", "<Esc>:q<cr>", { desc = "Quit window" })
map("n", "<M-Q>", "<Esc>:qa<cr>", { desc = "Quit all" })
map("n", "<leader>ct", "<Esc>:tabclose<cr>", { desc = "Close tab" })

-- Navigation
map("n", "<cr>", ":noh<cr><cr>", { desc = "Clear search highlight" })
map("n", "<Up>", "gk", { desc = "Move up (display line)" })
map("n", "<Down>", "gj", { desc = "Move down (display line)" })

-- Copy/paste with system clipboard
map("v", "<M-c>", '"+y<cr>', { desc = "Copy to system clipboard" })
map("n", "<M-v>", '"+P<cr>', { desc = "Paste from system clipboard" })
map("v", "<M-v>", '"+P<cr>', { desc = "Paste from system clipboard" })

-- Move lines up/down
map("n", "<M-Up>", ":m .-2<CR>==", { noremap = true, silent = true, desc = "Move line up" })
map("n", "<M-Down>", ":m .+1<CR>==", { noremap = true, silent = true, desc = "Move line down" })
map("v", "<M-Up>", ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move selection up" })
map("v", "<M-Down>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move selection down" })
