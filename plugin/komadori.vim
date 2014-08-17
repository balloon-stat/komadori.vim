if exists('g:loaded_komadori')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

let g:komadori_save_file     = get(g:, 'komadori_save_file', '~/vim.gif')
let g:komadori_periodic      = get(g:, 'komadori_periodic', 0)
let g:komadori_interval      = get(g:, 'komadori_interval', 30)
let g:komadori_margin_left   = get(g:, 'komadori_margin_left', 8)
let g:komadori_margin_top    = get(g:, 'komadori_margin_top', 82)
let g:komadori_margin_right  = get(g:, 'komadori_margin_right', 8)
let g:komadori_margin_bottom = get(g:, 'komadori_margin_bottom', 8)

let g:loaded_komadori = 1

let &cpo = s:save_cpo
unlet s:save_cpo
