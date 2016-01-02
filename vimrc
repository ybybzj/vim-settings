execute pathogen#infect()
syntax on
filetype plugin indent on
" syntastic settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" normal settings
set number
set noswapfile
set cursorline
set laststatus=2
set statusline+=%F
" set color scheme
set background=dark
colorscheme Monokai
set mouse=a

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" set tab to space, and shift width
set ts=2 sts=2 sw=2 expandtab

let mapleader=','

" shortcuts keymaps
" Quick write session with F2
map <F2> :mksession! ~/.vim_session <cr>
" And load session with F3
map <F3> :source ~/.vim_session <cr>
" AutoFormat with F4
map <F4> :Autoformat<cr>
" Toggle NERDTree"
map <leader>l :NERDTreeToggle<cr>
map <leader>vr :source ~/.vimrc<cr>
" Open buffer list, switch buffer
map <leader>b :ls<cr>:b<space>
map <C-l> :bn<cr>
map <C-h> :bp<cr>

" Open new tab
nnoremap <leader>t :enew<cr>:e /home/jackzj<cr>
nnoremap <leader>n :enew<cr>

" Edit .vimrc
nnoremap <leader>ve :e ~/.vimrc<cr>

" Edit i3config
nnoremap <leader>i3 :e ~/.config/i3/config<cr>

cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
map <leader>et :tabe %%

" mapping save operation
execute "set <M-s>=\es"
nnoremap <M-s> <Esc>:w<cr><Esc>
inoremap <M-s> <Esc>:w<cr>
" close window with <Alt-q>
execute "set <M-q>=\eq"
map <M-q> <Esc>:bp <BAR> bd #<cr>

" insert mode key bindings
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>
inoremap <silent> <C-W> <C-\><C-O>db
inoremap <silent> <C-U> <C-\><C-O>d0
inoremap <silent> <C-Y> <C-R>"
" vim-airline settings
let g:airline#extensions#tabline#enabled = 1
let g:airline#exsentions#tabline#fnamemod = ':t'

" Setting for ctrlP {{{
" Setup some default ignores
let g:ctrlp_custom_ignore = {
   \ 'dir':  '\v[\/](\.(git|hg|svn)|\_site)$',
   \ 'file': '\v\.(exe|so|dll|class|png|jpg|jpeg)$',
 \ }
" Use the nearest .git directory as the cwd
let g:ctrlp_working_path_mode = 'r'
