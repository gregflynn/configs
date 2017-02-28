set nocompatible
filetype off
let mapleader=' '

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle
Plugin 'VundleVim/Vundle.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'morhetz/gruvbox'
Plugin 'vim-airline/vim-airline'
Plugin 'Yggdroot/indentLine'
Plugin 'scrooloose/syntastic'
call vundle#end()
filetype plugin indent on

" Airline config options
let g:airline_powerline_fonts = 1
let g:airline_theme='gruvbox'
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#buffer_nr_show=1
set laststatus=2

" CtrlP config options
" Ignore some folders and files for CtrlP indexing
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\.git$\|public$\|log\|tmp$\|node_modules$',
  \ 'file': '\.so$\|\.dat$\|\.DS_Store$\|\.pyc$\|\.gz$\|\.class$'
  \ }

" Syntastic config options
let g:syntastic_check_on_open=1
let g:syntastic_enable_signs=0

syntax enable
:silent! colorscheme gruvbox
let g:gruvbox_contrast_dark='hard'
set background=dark
set number
set tabstop=4
set shiftwidth=4
set expandtab
set backspace=indent,eol,start
set colorcolumn=80

" Key mappings
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
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
map <Leader>p "*p
map <Leader>y "*y
" Make background transparent
hi Normal guibg=NONE ctermbg=NONE
" fix syntastic highlight colors
hi! link SyntasticError GruvboxRedSign
hi! link SyntasticWarning GruvboxYellowSign
