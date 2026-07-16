" Shared settings for vim and nvim
" Sourced by vimrc (leader=,) and nvim keymaps.lua (leader=Space)

" --- Options ---
set encoding=utf-8
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=4
set shiftround
set backspace=indent,eol,start
set number
set relativenumber
set cursorline
set wildmenu
set lazyredraw
set showmatch
set incsearch
set hlsearch
set noerrorbells
set modelines=0

" vim-only options (deprecated in nvim)
if !has('nvim')
  set ruler
  set showcmd
endif

" --- Keymaps ---
" jk to escape
inoremap jk <ESC>

" j/k move by visual line (wrapped lines)
nnoremap j gj
nnoremap k gk

" H/L for line extremes
nnoremap H ^
nnoremap L $

" Better split navigation
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Move line down/up
nnoremap <leader>- ddp
nnoremap <leader>_ ddkP

" Uppercase current word
inoremap <leader><C-U> <ESC>viwU<ESC>ie
nnoremap <leader><C-U> viwU<ESC>e

" Clear search highlight
nnoremap <leader><space> :nohlsearch<CR>

" Edit/source config
nnoremap <leader>ev :vsplit $MYVIMRC<CR>
nnoremap <leader>sv :source $MYVIMRC<CR>

" Quote-wrapping (normal mode — wrap word under cursor)
nnoremap <leader>" viw<ESC>a"<ESC>bi"<ESC>lel
nnoremap <leader>' viw<ESC>a'<ESC>bi'<ESC>lel
nnoremap <leader>` viw<ESC>a`<ESC>bi`<ESC>lel

" Quote-wrapping (visual mode — wrap selection)
vnoremap <leader>" <ESC>`>a"<ESC>`<i"<ESC>
vnoremap <leader>' <ESC>`>a'<ESC>`<i'<ESC>
vnoremap <leader>` <ESC>`>a`<ESC>`<i`<ESC>

" Text objects: inside/around next/last brackets
onoremap in( :<C-U>normal! f(vi(<CR>
onoremap in{ :<C-U>normal! f{vi{<CR>
onoremap il( :<C-U>normal! F)vi(<CR>
onoremap il{ :<C-U>normal! F}vi{<CR>
onoremap an( :<C-U>normal! f(<CR>
onoremap an{ :<C-U>normal! f{<CR>
onoremap al( :<C-U>normal! vF)l<CR>
onoremap al{ :<C-U>normal! vF}l<CR>

" Text objects: parameters
onoremap p i(

" --- Abbreviations ---
iabbrev adn and
iabbrev teh the
iabbrev waht what
iabbrev @@ edan.sneh@gmail.com
iabbrev ssig -- <CR>Edan Sneh<CR>edan.sneh@gmail.com

" --- Filetype autocmds ---
augroup filetype_sage
    au! BufRead,BufNewFile *.sage,*.spyx,*.pyx setfiletype python
augroup END

augroup on_read
    autocmd!
    autocmd BufNewFile,BufRead *.html :setlocal nowrap
augroup END

augroup filetype_js_c
    autocmd!
    autocmd FileType javascript,c,cpp :nnoremap <buffer> <localleader>c I//<esc>
    autocmd FileType javascript,c,cpp :iabbrev <buffer> iff if ()<left>
augroup END

augroup filetype_python
    autocmd!
    autocmd FileType python :nnoremap <buffer> <localleader>c I#<esc>
    autocmd FileType python :iabbrev <buffer> iff if:<left>
augroup END

augroup filetype_html
    autocmd!
    autocmd FileType html nnoremap <buffer> <localleader>f Vatzf
augroup END
