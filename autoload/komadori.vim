let s:save_cpo = &cpo
set cpo&vim

let s:path = expand('<sfile>:p:h')
let s:binpath = s:path . '\..\bin\'
let s:captured = 0
let s:has_posh = executable('powershell')
let s:has_magick = executable('import')
let s:count_file_prefix = 0
let s:has_vimproc = 0
silent! let s:has_vimproc = vimproc#version()

function! komadori#insert()
  augroup PluginKomadori
    autocmd!
    autocmd CursorMovedI * call komadori#capture()
    autocmd InsertLeave * call komadori#bundle() | echo 'komadori stop!'
  augroup END
  echo 'komadori start!'
  call getchar()
  startinsert
endfunction

function! komadori#periodic(time)
  if !s:has_posh
    echoerr 'This method needs PowerShell'
    return
  end
  let fpath = shellescape(s:binpath . 'periodic.ps1')
  let cmd = 'powershell -ExecutionPolicy RemoteSigned -NoProfile -File ' . fpath
  let margin = ' ' . 
        \   g:komadori_margin_left   . ' ' .
        \   g:komadori_margin_top    . ' ' .
        \   g:komadori_margin_right  . ' ' .
        \   g:komadori_margin_bottom
  let far = vimproc#shellescape(expand(g:komadori_save_file))
  let arg = join([far, a:time, g:komadori_interval])
  call system_gui(cmd . ' ' . arg . margin)
endfunction

function! komadori#capture()
  if s:has_posh
    if !s:captured
      let s:delays = ''
      let s:delay = g:komadori_interval
      let s:captured = 1
    endif
    let name = s:serialname()
    call vimproc#system_bg(s:oneshot_cmd(name))
    let s:delays .= s:delay . ' '
    let s:delay = g:komadori_interval
  elseif s:has_magick
    if executable('xdotool')
      if !s:captured
        let s:win_id = matchstr(system('xdotool getactivewindow'), '\d\+')
        let s:geometry = s:measure_geometry()
        let s:captured = 1
      endif
      let arg = ' -window ' . s:win_id . s:geometry
      let name = s:serialname()
      if s:has_vimproc
        call vimproc#system_bg('import' . arg . vimproc#shellescape(name))
      else
        call system('import' . arg . shellescape(name))
      endif
    else
      echoerr 'This plugin needs xdotool'
    endif
  else
    echoerr 'This plugin needs PowerShell or ImageMagick'
  endif
endfunction

function! s:oneshot_cmd(filename)
  let fpath = s:binpath  . 'oneshot.ps1'
  let cmd = ['powershell', '-ExecutionPolicy', 'RemoteSigned', '-NoProfile', '-Command']
  let margin = ' @(' . 
        \   g:komadori_margin_left   . ', ' .
        \   g:komadori_margin_top    . ', ' .
        \   g:komadori_margin_right  . ', ' .
        \   g:komadori_margin_bottom .
        \  ')'
  let save_cmd = ' | % { $_.save("' . a:filename . '")}'
  return cmd + [fpath . margin . save_cmd]
endfunction

function! s:measure_geometry()
  let geoinfo = system('xwininfo -id `xdotool getactivewindow`')
  let width = matchstr(geoinfo, 'Width: \zs\d\+') - g:komadori_margin_right
  let height = matchstr(geoinfo, 'Height: \zs\d\+') - g:komadori_margin_bottom
  if g:komadori_margin_left > 0
    let x = '+' . g:komadori_margin_left
  else
    let x = '-' . g:komadori_margin_left
  endif
  if g:komadori_margin_top > 0
    let y = '+' . g:komadori_margin_top
  else
    let y = '-' . g:komadori_margin_top
  endif
  return ' -crop ' . width . 'x' . height . x . y . ' '
endfunction

function! s:serialname()
  let s:count_file_prefix += 1
  let file = g:komadori_temp_dir . 'komadori_' . s:count_file_prefix . '.gif'
  return expand(file)
endfunction

function! komadori#bundle()
  augroup PluginKomadori
    autocmd!
  augroup END
  if !s:captured
    echo 'no capture'
    return
  endif
  let s:captured = 0
  if s:has_posh
    call s:bundle_posh()
    echo "create" g:komadori_save_file
  elseif s:has_magick
    call s:bundle_magick()
    echo "create" g:komadori_save_file
  else
    echoerr 'This plugin needs PowerShell or ImageMagick'
  endif
endfunction

function! s:bundle_posh()
  let fpath = vimproc#shellescape(s:binpath . 'bundle.ps1')
  let cmd = 'powershell -ExecutionPolicy RemoteSigned -NoProfile -File ' . fpath
  let arg = vimproc#shellescape(expand(g:komadori_save_file)) . ' ' .
        \   vimproc#shellescape(expand(g:komadori_temp_dir)) . ' ' .
        \   s:delays . s:delay
  call vimproc#system_bg(cmd . ' ' . arg)
  let s:count_file_prefix = 0
endfunction

function! s:bundle_magick()
  let cmd = 'convert -loop 0 -layers optimize -delay ' . g:komadori_interval
  let max = s:count_file_prefix
  let s:count_file_prefix = 0
  let infile = ''
  for i in range(1, max)
    let infile .= ' ' . shellescape(s:serialname())
  endfor
  let s:count_file_prefix = 0
  if s:has_vimproc
    call vimproc#system_bg(cmd . infile . ' ' . vimproc#shellescape(expand(g:komadori_save_file)))
  else
    call system(cmd . infile . ' ' . shellescape(expand(g:komadori_save_file)))
  endif
endfunction

function! komadori#keep()
  if s:has_posh
    let s:delay += g:komadori_interval
  else
    echoerr 'This method needs PowerShell'
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
