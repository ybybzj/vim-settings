" set the plugings path
call plug#begin('~/.config/nvim/plugged')

" plugins managed by vim-plug
Plug 'tpope/vim-sensible'
Plug 'scrooloose/nerdtree'
" Plug 'Xuyuanp/nerdtree-git-plugin'
" Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" Plug 'w0rp/ale'
Plug 'roxma/nvim-completion-manager'
" Plug 'autozimu/LanguageClient-neovim', {
"     \ 'branch': 'next',
"     \ 'do': 'bash install.sh',
"     \ }
Plug 'eugen0329/vim-esearch'
" Plug 'mhartington/nvim-typescript'
Plug 'tpope/vim-surround'
" Plug 'airblade/vim-gitgutter'
" Plug 'pangloss/vim-javascript'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
" Plug 'rust-lang/rust.vim'
" Plug 'cespare/vim-toml'
" Plug 'reasonml-editor/vim-reason-plus'
" Plug 'mattn/emmet-vim'
" ui plugins
Plug 'lifepillar/vim-solarized8'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()

