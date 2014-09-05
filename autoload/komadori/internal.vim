
let s:save_cpo = &cpo
set cpo&vim

let s:count_file_prefix = 0

function! komadori#internal#margin()
  return ' @(' .
        \   g:komadori_margin_left   . ', ' .
        \   g:komadori_margin_top    . ', ' .
        \   g:komadori_margin_right  . ', ' .
        \   g:komadori_margin_bottom .
        \  ')'
endfunction

function! komadori#internal#measure_geometry()
  let geoinfo = system('xwininfo -id `xdotool getactivewindow`')
  let width = matchstr(geoinfo, 'Width: \zs\d\+') - g:komadori_margin_right
  let height = matchstr(geoinfo, 'Height: \zs\d\+') - g:komadori_margin_bottom
  if g:komadori_margin_left >= 0
    let x = '+' . g:komadori_margin_left
  else
    let x = '' . g:komadori_margin_left
  endif
  if g:komadori_margin_top >= 0
    let y = '+' . g:komadori_margin_top
  else
    let y = '' . g:komadori_margin_top
  endif
  return width . 'x' . height . x . y . ' '
endfunction

function! komadori#internal#serialname()
  let s:count_file_prefix += 1
  let file = printf('%skomadori_%03d.gif', g:komadori_temp_dir, s:count_file_prefix)
  return expand(file)
endfunction

function! komadori#internal#reset_count()
  let s:count_file_prefix = 0
endfunction

function! komadori#internal#prefix_count()
  return s:count_file_prefix
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
