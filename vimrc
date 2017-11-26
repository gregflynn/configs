set nocompatible
filetype off

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle
Plugin 'VundleVim/Vundle.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'Yggdroot/indentLine'
Plugin 'majutsushi/tagbar'
Plugin 'crusoexia/vim-monokai'
Plugin 'nvie/vim-flake8'
Plugin 'tpope/vim-vinegar'
Plugin 'Valloric/YouCompleteMe'
Plugin 'mustache/vim-mustache-handlebars'
Plugin 'scrooloose/nerdcommenter'
call vundle#end()
filetype plugin indent on

" Airline config options
let g:airline_powerline_fonts = 1
let g:airline_theme='molokai'
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#buffer_nr_show=1
set laststatus=2

" CtrlP config options
" Ignore some folders and files for CtrlP indexing
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\.git$\|public$\|log\|tmp$\|node_modules$',
  \ 'file': '\.so$\|\.dat$\|\.DS_Store$\|\.pyc$\|\.gz$\|\.class$'
  \ }

" youcompleteme
:let g:ycm_auto_trigger = 0
:let g:ycm_python_binary_path = 'python'
:let g:ycm_server_python_interpreter = '/usr/bin/python2'

" netrw config
let g:netrw_liststyle = 3
let g:netrw_browse_split = 4
let g:netrw_winsize = 20
map <C-\> :Lexplore<cr>

syntax enable
:silent! colorscheme monokai
:silent! set t_Co=256
:silent! set termguicolors
let g:monokai_term_italic = 1
let g:monokai_gui_italic = 1
set background=dark
set number
set tabstop=4
set shiftwidth=4
set expandtab
set backspace=indent,eol,start
set colorcolumn=80,120

" Key mappings
:let mapleader = "\\"
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
nnoremap <C-K><C-K> <C-W><C-W>
nnoremap <Leader>q :bd<CR>
nnoremap <Leader>j :ls<CR>
nnoremap <Leader>h :bp<CR>
nnoremap <Leader>l :bn<CR>
nnoremap <Leader>1 :1b<CR>
nnoremap <Leader>2 :2b<CR>
nnoremap <Leader>3 :3b<CR>
nnoremap <Leader>4 :4b<CR>
nnoremap <Leader>5 :5b<CR>
nnoremap <Leader>6 :6b<CR>
nnoremap <Leader>7 :7b<CR>
nnoremap <Leader>8 :8b<CR>
nnoremap <Leader>9 :9b<CR>
nnoremap <Leader>0 :10b<CR>
map <C-D> dd
map <Leader>p "+p
map <Leader>y "+y
map <C-F> :CtrlPTag<cr>
map <C-G> :!ctags -R -f tags --exclude=node_modules --exclude=__pycache__ --exclude=dist --exclude=tmp --exclude=bower_components --python-kinds=-i<cr>
map <Leader>t :TagbarToggle<CR>
:nnoremap <silent><expr> <Leader>/ (&hls && v:hlsearch ? ':nohls' : ':set hls')."\n"

" move line up/down
nnoremap <C-Down> :m .+1<CR>==
nnoremap <C-Up> :m .-2<CR>==
inoremap <C-Down> <Esc>:m .+1<CR>==gi
inoremap <C-Up> <Esc>:m .-2<CR>==gi
vnoremap <C-Down> :m '>+1<CR>gv=gv
vnoremap <C-Up> :m '<-2<CR>gv=gv

" save file
nnoremap <C-S> :w<CR>
inoremap <C-S> :w<CR>
vnoremap <C-S> :w<CR>

" indent in visual mode like a champ
vnoremap < <gv
vnoremap > >gv

" comment out lines of code
map <C-_> <leader>c<space>

set cursorline
set mouse=a
