let s:background = {'hex': '#2D2A2E', 'term': 16}
let s:gray       = {'hex': '#939293', 'term': 246}
let s:white      = {'hex': '#FCFCFA', 'term': 231}

let s:black   = {'hex': '#727072', 'term': 59}
let s:yellow  = {'hex': '#FFD866', 'term': 221}
let s:orange  = {'hex': '#FC9867', 'term': 209}
let s:red     = {'hex': '#FF6188', 'term': 204}
let s:purple  = {'hex': '#AB9DF2', 'term': 147}
let s:blue    = {'hex': '#78DCE8', 'term': 116}
let s:green   = {'hex': '#A9DC76', 'term': 150}

let g:airline#themes#monokaipro#palette = {}



" Normal mode
let s:N1 = [s:background['hex'], s:yellow['hex'], s:background['term'], s:yellow['term']]
let s:N2 = [s:white['hex'], s:background['hex'], s:white['term'], s:background['term']]
let s:N3 = [s:white['hex'], s:background['hex'], s:white['term'], s:background['term']]

let g:airline#themes#monokaipro#palette.normal = airline#themes#generate_color_map(s:N1, s:N2, s:N3)
let g:airline#themes#monokaipro#palette.normal_modified = {
      \ 'airline_c': [s:background['hex'], s:yellow['hex'], s:background['term'], s:yellow['term'], ''],
      \ }



" Insert mode
let s:I1 = [s:background['hex'], s:blue['hex'], s:background['term'], s:blue['term']]
let s:I2 = [s:white['hex'], s:background['hex'], s:white['term'], s:background['term']]
let s:I3 = [s:white['hex'], s:background['hex'], s:white['term'], s:background['term']]

let g:airline#themes#monokaipro#palette.insert = airline#themes#generate_color_map(s:I1, s:I2, s:I3)
let g:airline#themes#monokaipro#palette.insert_modified = {
      \ 'airline_c': [s:background['hex'], s:blue['hex'], s:background['term'], s:blue['term'], ''],
      \ }



" Replace mode
let s:R1 = [s:background['hex'], s:red['hex'], s:background['term'], s:red['term']]
let s:R2 = [s:white['hex'], s:background['hex'], s:white['term'], s:background['term']]
let s:R3 = [s:white['hex'], s:background['hex'], s:white['term'], s:background['term']]

let g:airline#themes#monokaipro#palette.replace = airline#themes#generate_color_map(s:R1, s:R2, s:R3)
let g:airline#themes#monokaipro#palette.replace_modified = {
      \ 'airline_c': [s:background['hex'], s:red['hex'], s:background['term'], s:red['term'], ''],
      \ }



" Visual mode
let s:V1 = [s:background['hex'], s:green['hex'], s:background['term'], s:green['term']]
let s:V2 = [s:white['hex'], s:background['hex'], s:white['term'], s:background['term']]
let s:V3 = [s:white['hex'], s:background['hex'], s:white['term'], s:background['term']]

let g:airline#themes#monokaipro#palette.visual = airline#themes#generate_color_map(s:V1, s:V2, s:V3)
let g:airline#themes#monokaipro#palette.visual_modified = {
      \ 'airline_c': [s:background['hex'], s:green['hex'], s:background['term'], s:green['term'], ''],
      \ }



" Inactive
let s:IA = [s:white['hex'], s:background['hex'], s:white['term'], s:background['term']]
let g:airline#themes#monokaipro#palette.inactive = airline#themes#generate_color_map(s:IA, s:IA, s:IA)
let g:airline#themes#monokaipro#palette.inactive_modified = {
      \ 'airline_c': [s:orange['hex'], s:background['hex'], s:orange['term'], s:background['term'], ''],
      \ }



" CtrlP
if !get(g:, 'loaded_ctrlp', 0)
  finish
endif
let g:airline#themes#monokaipro#palette.ctrlp = airline#extensions#ctrlp#generate_color_map(
      \ [s:white['hex'], s:background['hex'], s:white['term'], s:background['term'], ''],
      \ [s:white['hex'], s:background['hex'], s:white['term'], s:background['term'], ''],
      \ [s:background['hex'], s:purple['hex'], s:background['term'], s:purple['term'], ''])

