execute pathogen#infect()
syntax on
filetype plugin indent on
" syntastic settings
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

" normal settings
set number
set relativenumber
set noswapfile
set cursorline
set laststatus=2
set statusline+=%F
" set color scheme
set t_Co=256
set background=light
colorscheme PaperColor
let g:airline_theme='PaperColor'
let g:PaperColor_Light_Override = { 'cursorline' : '#dfffff', 'matchparen': '#00afff'}

set mouse=a
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
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
nnoremap <leader>i3 :e ~/.i3/config<cr>

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

" ctrlp settings
let g:ctrlp_working_path_mode = 'ra'

" YouCompleteMe settings
let g:ycm_min_num_of_chars_for_completion = 2
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_complete_in_comments = 1
let g:ycm_key_list_select_completion = ['<c-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<c-b>', '<Up>']

" NERDTress File highlighting
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
 exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
 exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

call NERDTreeHighlightFile('jade', 'green', 'none', 'green', '#151515')
call NERDTreeHighlightFile('ini', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('md', 'blue', 'none', '#3366FF', '#151515')
call NERDTreeHighlightFile('yml', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('config', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('conf', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('json', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('html', 'yellow', 'none', 'yellow', '#151515')
call NERDTreeHighlightFile('styl', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('css', 'cyan', 'none', 'cyan', '#151515')
call NERDTreeHighlightFile('coffee', 'Red', 'none', 'red', '#151515')
call NERDTreeHighlightFile('js', 'Red', 'none', '#ffa500', '#151515')
call NERDTreeHighlightFile('php', 'Magenta', 'none', '#ff00ff', '#151515')

" setup rust
let g:rustfmt_autosave = 1
let g:ycm_rust_src_path = '/opt/rust/rustc-1.8.0/src'

" setup sudo write
command W :execute ':silent w !sudo tee % > /dev/null' | :edit!
