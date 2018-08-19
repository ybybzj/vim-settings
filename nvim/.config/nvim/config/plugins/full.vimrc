" set the plugings path
call plug#begin('~/.config/nvim/plugged')

" plugins managed by vim-plug
Plug 'tpope/vim-sensible'
Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'filipekiss/nvim-completion-manager'
Plug 'eugen0329/vim-esearch'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'

" development {{
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tpope/vim-fugitive'
Plug 'w0rp/ale'
Plug 'autozimu/LanguageClient-neovim', {
    \ 'branch': 'next',
    \ 'do': 'bash install.sh',
    \ }
Plug 'mhartington/nvim-typescript'
Plug 'airblade/vim-gitgutter'
Plug 'pangloss/vim-javascript'
Plug 'rust-lang/rust.vim'
Plug 'cespare/vim-toml'
Plug 'reasonml-editor/vim-reason-plus'
Plug 'mattn/emmet-vim'
"  development }}

" ui plugins
Plug 'lifepillar/vim-solarized8'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
call plug#end()


