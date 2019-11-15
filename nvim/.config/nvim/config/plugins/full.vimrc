" set the plugings path
call plug#begin('~/.config/nvim/plugged')

" plugins managed by vim-plug
Plug 'tpope/vim-sensible'
Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" auto completion
" development
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'ryanoasis/vim-devicons'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'w0rp/ale'
" git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
" reasonml
Plug 'reasonml-editor/vim-reason-plus' 
Plug 'jordwalke/vim-reasonml' 
" rust
Plug 'rust-lang/rust.vim'
" filetype
Plug 'neoclide/jsonc.vim'
" utilities
Plug 'cespare/vim-toml'
Plug 'mhinz/vim-grepper'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
" Plug 'Shougo/denite.nvim'

" ui plugins
Plug 'kaicataldo/material.vim'
Plug 'lifepillar/vim-solarized8'
Plug 'liuchengxu/eleline.vim'
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
call plug#end()

