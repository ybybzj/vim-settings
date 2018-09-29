" NCM2 start
autocmd BufEnter * call ncm2#enable_for_buffer()
inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
set completeopt=noinsert,menuone,noselect
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

" Reason/Ocaml Start
let g:vimreason_extra_args_expr_reason = '"--print-width " . ' .  "min([80, winwidth('.')])"
" Reason/Ocaml End

" Language Server Client Start
let g:LanguageClient_autoStart = 1
let g:LanguageClient_serverCommands = {
  \ 'reason': ['reason-language-server.exe'],
  \ 'rust': ['rls'],
  \ 'javascript': ['typescript-language-server', '--stdio'],
  \ 'javascript.jsx': ['typescript-language-server', '--stdio'],
  \ 'typescript': ['typescript-language-server', '--stdio'],
  \ 'sh': ['bash-language-server', 'start'],
  \ }
let g:LanguageClient_selectionUI = "fzf"

nnoremap <silent> gd :call LanguageClient_textDocument_definition()<cr>
" nnoremap <silent> <F4> :call LanguageClient_textDocument_formatting()<cr>
nnoremap <silent> <space> :call LanguageClient_textDocument_hover()<cr>
nnoremap <silent> gs :call LanguageClient_textDocument_documentSymbol()<cr>
nnoremap <silent> gf :call LanguageClient_textDocument_codeAction()<cr>
" Language Server Client End

" Emmet Start
let g:user_emmet_install_global = 0
autocmd FileType html,css,jsx EmmetInstall
" Emmet End

" ale {{{
let g:ale_linters = {
\   'javascript': ['eslint'],
\   'typescript': ['tslint'],
\   'sass': ['prettier'],
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
nnoremap <silent> <leader>F :Grepper -tool ag -cword -noprompt<cr>
nmap gS <Plug>(GrepperOperator)
xmap gS <Plug>(GrepperOperator)
let g:grepper               = {}
let g:grepper.tools         = ['ag', 'git', 'rg']
let g:grepper.repo          = ['.git', '.hg', '.svn']
let g:grepper.dir           = 'repo,file'
let g:grepper.jump          = 0
let g:grepper.next_tool     = '<leader>g'
let g:grepper.simple_prompt = 1
let g:grepper.quickfix      = 0
" vim-grepper }}}

" fzf {{{
nnoremap <C-p> :Files ~<cr>
nnoremap <C-b> :History<cr>
" fzf }}}
