set nocompatible
filetype plugin indent on
syntax on

set termguicolors
set number
"set relativenumber
set noswapfile
set cursorline
set laststatus=2
set statusline+=%F
set showmode
set wildignore+=*/tmp/*,*.so,*.swp,*.zip

" set auto change dir
autocmd BufEnter * silent! lcd %:p:h

" set tab to space, and shift width
set ts=2 sts=2 sw=2 expandtab

set mouse=a

" setup sudo write
command! W :execute ':silent w !sudo tee % > /dev/null' | :edit!

