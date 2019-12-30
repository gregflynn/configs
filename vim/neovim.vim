set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc
autocmd VimEnter * GitGutterLineNrHighlightsEnable

hi link GitGutterAddLineNr Function
hi link GitGutterChangeLineNr String
hi link GitGutterDeleteLineNr Define
hi link GitGutterChangeDeleteLineNr Define
set signcolumn=no

