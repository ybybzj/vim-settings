" NCM2 start
" autocmd BufEnter * call ncm2#enable_for_buffer()
" inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
" inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
" set completeopt=noinsert,menuone,noselect
" NCM2 end

" NERDTree Start
function! NERDTreeHighlightFile(extension, fg, bg, guifg, guibg)
  exec 'autocmd filetype nerdtree highlight ' . a:extension .' ctermbg='. a:bg .' ctermfg='. a:fg .' guibg='. a:guibg .' guifg='. a:guifg
  exec 'autocmd filetype nerdtree syn match ' . a:extension .' #^\s\+.*'. a:extension .'$#'
endfunction

let NERDTreeShowHidden=1

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
" NERDTree End

" {-- Reason/Ocaml Start
let g:vimreason_extra_args_expr_reason = '"--print-width " . ' .  "min([80, winwidth('.')])"
" Reason/Ocaml End --}

" Language Server Client Start
" let g:LanguageClient_autoStart = 1
" let g:LanguageClient_serverCommands = {
"   \ 'reason': ['reason-language-server'],
"   \ 'rust': ['rls'],
"   \ 'javascript': ['typescript-language-server', '--stdio'],
"   \ 'javascript.jsx': ['typescript-language-server', '--stdio'],
"   \ 'typescript': ['typescript-language-server', '--stdio'],
"   \ 'sh': ['bash-language-server', 'start'],
"   \ }
" let g:LanguageClient_selectionUI = "fzf"

" nnoremap <silent> gd :call LanguageClient_textDocument_definition()<cr>
" " nnoremap <silent> <F4> :call LanguageClient_textDocument_formatting()<cr>
" nnoremap <silent> <space> :call LanguageClient_textDocument_hover()<cr>
" nnoremap <silent> gs :call LanguageClient_textDocument_documentSymbol()<cr>
" nnoremap <silent> gf :call LanguageClient_textDocument_codeAction()<cr>
" Language Server Client End

" {-- CoC (Conquer of Completion)
set hidden
set cmdheight=2
set signcolumn=yes
set shortmess+=c
  "" Use tab for trigger completion with characters ahead and navigate.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <cr> for confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Use `[c` and `]c` for navigate diagnostics
nmap <silent> [c <Plug>(coc-diagnostic-prev)
nmap <silent> ]c <Plug>(coc-diagnostic-next)

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K for show documentation in preview window
nnoremap <silent> <space> :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if &filetype == 'vim'
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

" Remap for format selected region
vmap <leader>ff  <Plug>(coc-format-selected)
nmap <leader>ff  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
vmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap for do codeAction of current line
nmap <leader>ac  <Plug>(coc-codeaction)
" Fix autofix problem of current line
nmap <leader>qf  <Plug>(coc-fix-current)

" Use `:Format` for format current buffer
command! -nargs=0 Format :call CocAction('format')

" Use `:Fold` for fold current buffer
command! -nargs=? Fold :call     CocAction('fold', <f-args>)
" Shortcuts for denite interface
" Show extension list
nnoremap <silent> <space>e  :<C-u>Denite coc-extension<cr>
" Show symbols of current buffer
nnoremap <silent> <space>o  :<C-u>Denite coc-symbols<cr>
" Search symbols of current workspace
nnoremap <silent> <space>t  :<C-u>Denite coc-workspace<cr>
" Show diagnostics of current workspace
nnoremap <silent> <space>a  :<C-u>Denite coc-diagnostic<cr>
" Show available commands
nnoremap <silent> <space>c  :<C-u>Denite coc-command<cr>
" Show available services
nnoremap <silent> <space>s  :<C-u>Denite coc-service<cr>
" Show links of current buffer
nnoremap <silent> <space>l  :<C-u>Denite coc-link<cr>
" --}

" Emmet Start
let g:user_emmet_install_global = 0
autocmd FileType html,css,jsx EmmetInstall
" Emmet End

" ale {{{
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'typescript': ['tslint'],
\   'sass': ['prettier'],
\   'reason': ['merlin'],
\}
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'javascript': ['prettier'],
\   'typescript': ['prettier'],
\   'rust': ['rls'],
\   'reason': ['refmt'],
\}
nmap <silent> <F7> <Plug>(ale_previous_wrap)
nmap <silent> <F8> <Plug>(ale_next_wrap)
nnoremap <silent> <F4> :ALEFix<cr>
" ale }}}

" vim-grepper {{{
nnoremap <silent> <space>f :Grepper -tool rg -cword -noprompt -highlight<cr>
nmap <silent> gf <Plug>(GrepperOperator)
xmap <silent> gf <Plug>(GrepperOperator)
let g:grepper               = {}
let g:grepper.tools         = ['git', 'ag', 'rg']
let g:grepper.dir           = 'repo,file'
let g:grepper.repo          = ['.git', '.hg', '.svn']
let g:grepper.jump          = 0
let g:grepper.next_tool     = '<leader>g'
let g:grepper.simple_prompt = 1
let g:grepper.quickfix      = 0
" vim-grepper }}}

" fzf {{{
nnoremap <C-p> :Files ~<cr>
nnoremap <C-b> :History<cr>
" fzf }}}

" reasonml-vim {{{
" Airline: Enable the airline extensions for esy project status and reason
  " syntastic plugin.
  let g:airline_extensions = ['tabline', 'esy', 'reason']
  let g:reasonml_project_airline=1
  let g:reasonml_syntastic_airline=1
  " Unrelated to reason, but nice cleanup of the statusline.
  let g:reasonml_clean_project_airline=1
  " Not necessary when using refmt!
  let g:airline#extensions#whitespace#enabled = 0
  let g:airline_powerline_fonts = 1
  let g:airline_skip_empty_sections = 1
  " autocmd FileType reason map <buffer> <D-C> :ReasonPrettyPrint<Cr><Paste>
" reasonml-vim }}}
