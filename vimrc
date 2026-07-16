" improve vim (not vi compatible)
set nocompatible

" force plugins to be compatible
filetype off

" load plugins here via Vundle
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" put rest of plugins here
Plugin 'tpope/vim-fugitive'
Plugin 'scrooloose/nerdtree'
Plugin 'ervandew/supertab'
Plugin 'bling/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'majutsushi/tagbar'
Plugin 'fatih/vim-go'
Plugin 'michalbachowski/vim-wombat256mod'

call vundle#end()

" for plugins to load correctly
filetype plugin indent on

" turn on syntax highlighting
syntax enable

" set dark background
set background=dark

" set colorscheme
colorscheme wombat256mod

" disable cterm bg (so transparency works)
hi Normal guibg=NONE ctermbg=NONE
hi NonText ctermbg=none

" enable powerline fonts for vim-airline
let g:airline_powerline_fonts = 1

" enable ctags so tagbar works
if executable('ctags')
  let g:Tlist_Ctags_Cmd=exepath('ctags')
endif

" set leader to be comma
let mapleader=","
let maplocalleader="\\"

" Shared settings (options, keymaps, autocmds, abbreviations)
if filereadable(expand("~/.config/nvim/shared.vim"))
  source ~/.config/nvim/shared.vim
endif

" map ",n" to NERDTree
noremap <Leader>n :NERDTreeToggle<CR>

" map ",m" to Tagbar
noremap <Leader>m :TagbarToggle<CR>
