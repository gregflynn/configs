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
Plugin 'mustache/vim-mustache-handlebars'
Plugin 'scrooloose/nerdcommenter'
Plugin 'airblade/vim-gitgutter'
call vundle#end()
filetype plugin indent on

" CtrlP config options
" Ignore some folders and files for CtrlP indexing
let g:ctrlp_custom_ignore = {
  \ 'dir':  '\.git$\|public$\|log\|tmp$\|node_modules$',
  \ 'file': '\.so$\|\.dat$\|\.DS_Store$\|\.pyc$\|\.gz$\|\.class$'
  \ }
map <C-P> :CtrlP<cr>
map <C-B> :CtrlPBuffer<cr>
map <C-F> :CtrlPTag<cr>

" Git Gutter
let g:gitgutter_override_sign_column_highlight = 0
map <Leader>d :GitGutterLineHighlightsToggle<cr>
hi link GitGutterAdd Function
hi link GitGutterChange String
hi link GitGutterDelete Define
hi link GitGutterChangeDelete Define
let g:gitgutter_sign_modified = '>'
let g:gitgutter_sign_modified_removed = '>'

" Airline config options
let g:airline_powerline_fonts = 1
let g:airline_section_y = ''
let g:airline_section_z = ''
let g:airline_theme='molokai'

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
map <C-D> dd
map <Leader>p "+p
map <Leader>y "+y
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

map <C-K><C-W> :bufdo bwipeout<CR>

" quit
nnoremap <C-Q> <Esc>:q<CR>
inoremap <C-Q> <Esc>:q<CR>
vnoremap <C-Q> <Esc>:q<CR>

" save file
nnoremap <C-S> <Esc>:w<CR>
inoremap <C-S> <Esc>:w<CR>
vnoremap <C-S> <Esc>:w<CR>

" indent in visual mode like a champ
vnoremap < <gv
vnoremap > >gv

" comment out lines of code
map <C-_> <leader>c<space>

" fix ctrl left/right in normal mode
nnoremap <C-Left> b
nnoremap <C-Right> w

" don't open newly created files from netrw
" https://stackoverflow.com/questions/45536346/create-a-new-file-but-not-open-a-buffer-in-vim-netrw
autocmd filetype netrw call Netrw_mappings()
function! Netrw_mappings()
  noremap <buffer>% :call CreateInPreview()<cr>
endfunction
function! CreateInPreview()
  let l:filename = input("please enter filename: ")
  execute 'silent !touch ' . b:netrw_curdir.'/'.l:filename
  redraw!
endf

set cursorline
set mouse=a
