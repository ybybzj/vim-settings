let mapleader=','
let maplocalleader=';'
set pastetoggle=<leader>p

" shortcuts keymaps
" Quick write session with F2
map <F2> :mksession! ~/.vim_session <cr>
"
" And load session with F3
map <F3> :source ~/.vim_session <cr>
"
" Toggle NERDTree"
map <leader>l :NERDTreeToggle<cr>
"
" Open buffer list, switch buffer
map <leader>b :ls<cr>:b<space>
map <C-l> :bn<cr>
map <C-h> :bp<cr>

" Open new tab, switch tab
nnoremap <C-q> :tabclose<cr>
nnoremap <C-right> :tabnext<cr>
nnoremap <C-left> :tabprevious<cr>

" Edit .vimrc
map <leader>vr :source ~/.config/nvim/init.vim<cr>
nnoremap <leader>ve :e ~/.config/nvim/config<cr>

" Edit i3config
nnoremap <leader>i3 :e ~/.i3/config<cr>

cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
map <leader>ew :e %%
map <leader>es :sp %%
map <leader>ev :vsp %%
" map <leader>et :tabe %%
map <C-t> :tabe %%<cr>

" remap movement to move by column layout
nnoremap j gj
nnoremap k gk
noremap <Down> gj
noremap <Up> gk


" mapping save operation
" execute "set <M-s>=\es"
nnoremap <M-s> <Esc>:w<cr><Esc>
inoremap <M-s> <Esc>:w<cr>
"
" close window with <Alt-q>
" execute "set <M-q>=\eq"
map <M-q> <Esc>:q<cr>

" insert mode key bindings
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>
inoremap <silent> <C-W> <C-\><C-O>db
inoremap <silent> <C-U> <C-\><C-O>d0
inoremap <silent> <C-Y> <C-R>"

" terminal mode key bindings
:tnoremap <Esc> <C-\><C-n>
map <leader>t :sp %%<cr>:e term://bash<cr> <C-W>J
map <leader>tv :vsp %%<cr>:e term://bash<cr> <C-W>L

