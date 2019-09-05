" set the plugings path
call plug#begin('~/.config/nvim/plugged')

" plugins managed by vim-plug
Plug 'tpope/vim-sensible'
Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" auto completion
Plug 'roxma/nvim-yarp'
" Plug 'ncm2/ncm2'
" Plug 'ncm2/ncm2-path'
" Plug 'ncm2/ncm2-bufword'
" Language server
" Plug 'autozimu/LanguageClient-neovim', {
"   \ 'branch': 'next',
"   \ 'do': 'bash install.sh'
"   \ }

" development
Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
Plug 'ryanoasis/vim-devicons'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'tpope/vim-fugitive'
Plug 'w0rp/ale'
" javascript
" Plug 'ncm2/ncm2-tern', {'do': 'npm install'} 
" typescript
Plug 'HerringtonDarkholme/yats.vim'
" Plug 'mhartington/nvim-typescript', {'do':'./install.sh'} 
Plug 'airblade/vim-gitgutter'
Plug 'cespare/vim-toml'
" reasonml
Plug 'reasonml-editor/vim-reason-plus' 
Plug 'jordwalke/vim-reasonml' 
" css
" Plug 'ncm2/ncm2-cssomni'
" rust
Plug 'rust-lang/rust.vim'
" filetype
Plug 'neoclide/jsonc.vim'
" utilities
Plug 'mhinz/vim-grepper'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-commentary'
Plug 'Shougo/denite.nvim'

" ui plugins
Plug 'kaicataldo/material.vim'
Plug 'lifepillar/vim-solarized8'
Plug 'liuchengxu/eleline.vim'
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
call plug#end()



