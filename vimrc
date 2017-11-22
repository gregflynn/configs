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

syntax enable
:silent! colorscheme monokai
:silent! set t_Co=256
:silent! set termguicolors
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
map <Leader>p "*p
map <Leader>y "*y
map <C-F> :CtrlPTag<cr>
map <C-G> :!ctags -R -f tags --exclude=node_modules --exclude=__pycache__ --exclude=dist --exclude=tmp --exclude=bower_components<cr>
map <Leader>t :TagbarToggle<CR>

set cursorline
