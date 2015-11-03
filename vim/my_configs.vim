try
    colorscheme foursee
catch
endtry

" Git
au FileType gitcommit setlocal tw=72

" Show line numbers in tagbar
let g:tagbar_show_linenumbers = 1

" Show tabs
set list
set listchars=trail:.,tab:>.

" Double enter in normal mode inserts a newline and aligns the text
nnoremap <CR><CR> a<CR><Esc>==

" Julia block-wise movement requires matchit
runtime macros/matchit.vim

let g:ycm_collect_identifiers_from_tags_files = 1
":set tags=.git/tags;
":let g:easytags_dynamic_files = 2
" Local replace
"
" nnoremap gr gd[{V%::s/<C-R>///gc<left><left><left>
" The above didn't work in Julia... but probably works in other languages. In
" julia, the best we could do is use spacing to detect scopes.
nnoremap gr gd[[V][::s/<C-R>///gc<left><left><left>
" Global replace
nnoremap gR gD:%s/<C-R>///gc<left><left><left>

"------------------------------------------------------------------------------
" Vim-go
"------------------------------------------------------------------------------
let g:go_fmt_fail_silently = 1

" Show a list of interfaces which is implemented by the type under your cursor
au FileType go nmap <Leader>s <Plug>(go-implements)

" Show type info for the word under your cursor
au FileType go nmap <Leader>i <Plug>(go-info)

" Open the relevant Godoc for the word under the cursor
au FileType go nmap <Leader>gd <Plug>(go-doc)
au FileType go nmap <Leader>gv <Plug>(go-doc-vertical)

" Open the Godoc in browser
au FileType go nmap <Leader>gb <Plug>(go-doc-browser)

" Run/build/test/coverage
au FileType go nmap <leader>r <Plug>(go-run)
au FileType go nmap <leader>b <Plug>(go-build)
au FileType go nmap <leader>t <Plug>(go-test)
au FileType go nmap <leader>c <Plug>(go-coverage)
au FileType go nmap <leader>gi <Plug>(go-install)
" By default syntax-highlighting for Functions, Methods and Structs is disabled.
" Let's enable them!
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_fmt_command = "goimports"

"------------------------------------------------------------------------------
" NERDTree
"------------------------------------------------------------------------------

" General properties
let NERDTreeDirArrows=1
let NERDTreeMinimalUI=1
let NERDTreeIgnore=['\.o$', '\.pyc$', '\.php\~$']
let NERDTreeWinSize = 35

" Make sure that when NT root is changed, Vim's pwd is also updated
let NERDTreeChDirMode = 2
let NERDTreeShowLineNumbers = 1
let NERDTreeAutoCenter = 1

" Open NERDTree on startup, when no file has been specified
autocmd VimEnter * if !argc() | NERDTree | endif

" Locate file in hierarchy quickly
map <leader>T :NERDTreeFind<cr>

" Tagbar
map <leader>tb :TagbarToggle<CR>

set number

" Set a couple markers
set colorcolumn=80,120
" Highlight current line - allows you to track cursor position more easily
set cursorline
