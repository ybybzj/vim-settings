local opt = vim.opt -- to set options
local cmd = vim.cmd

------------------Default Settings-------------------
opt.completeopt = { "menuone", "noselect" }
opt.expandtab = true -- Use spaces instead of tabs
opt.hidden = true -- Enable background buffers
opt.ignorecase = true -- Ignore case
opt.joinspaces = false -- No double spaces with join
opt.list = true -- Show some invisible characters
opt.number = true -- Show line numbers
opt.relativenumber = true -- Relative line numbers
opt.scrolloff = 4 -- Lines of context
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.sidescrolloff = 8 -- Columns of context
opt.smartcase = true -- Do not ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.tabstop = 2 -- Number of spaces tabs count for
opt.termguicolors = true -- True color support
opt.timeoutlen = 150 -- Time in milliseconds to wait for a mapped sequence to complete.
opt.wildmode = { "list", "longest" } -- Command-line completion mode
opt.wrap = true -- Disable line wrap
cmd("set mouse=a")
cmd("set noswapfile")

-- copypaste with system clipboard
opt.clipboard = "unnamedplus"
