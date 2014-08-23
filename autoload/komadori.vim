let s:save_cpo = &cpo
set cpo&vim

let s:path = expand('<sfile>:p:h')
let s:binpath = s:path . '\..\bin\'
let s:captured = 0
let s:has_posh = executable('powershell')
let s:has_magick = executable('import')
let s:has_magick_convert = executable('convert')
let s:count_file_prefix = 0
let s:has_vimproc = 0
silent! let s:has_vimproc = vimproc#version()
let s:run_periodic_sh = 0
let s:run_periodic_py = 0

let s:path = expand("<sfile>:p:h")
python <<EOM
import os.path, sys, vim
binpath = os.path.join(vim.eval('s:path'), '..', 'bin')
if not binpath in sys.path:
  sys.path.append(binpath)
from periodic import Periodic
import gyazo
EOM

function! komadori#insert()
  augroup PluginKomadori
    autocmd!
    autocmd CursorMovedI * silent call komadori#capture()
    autocmd InsertLeave * call komadori#bundle() | echo 'komadori stop!'
  augroup END
  echo 'komadori start!'
  call getchar()
  startinsert
endfunction

function! komadori#periodic(time)
  if s:has_posh
    if has('python') && g:komadori_use_python
      call s:periodic_py(a:time)
      python periodic.runWith('posh')
    else
      call s:periodic_posh(a:time)
    endif
  elseif s:has_magick
    if s:has_vimproc && executable('xdotool')
      if has('python') && g:komadori_use_python
        call s:periodic_py(a:time)
        python periodic.runWith('magick')
      else
        call s:periodic_sh(a:time)
      endif
    else
      if s:has_vimproc
        echoerr 'This plugin needs xdotool'
      elseif executable('xdotool')
        echoerr 'This method needs vimproc'
      else
        echoerr 'This method needs xdotool and vimproc'
      endif
    endif
  else
    echoerr 'This plugin needs PowerShell or ImageMagick'
  endif
endfunction

function! s:periodic_posh(time)
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

function! s:preproc_periodic()
  let tmps = expand(g:komadori_temp_dir) . 'komadori_*.gif'
  if s:has_posh
    let cmd = 'del ' . tmps
  else
    let cmd = 'rm ' . tmps
  endif
  if len(glob(tmps))
    echo 'run? ' . cmd . ', for initialize. (y)es or (n)o: '
    let ch = ''
    while ! (ch == 'y' || ch == 'n')
      let ch = nr2char(getchar())
    endwhile
    if ch == 'y'
      if s:has_vimproc
        if s:has_posh
          let cmd = 'cmd /c ' . cmd
        endif
        call vimproc#system(split(cmd))
      else
        silent execute '!' cmd
      endif
    endif
  endif
  redraw
  echo 'start to push any key and finish to execute ComadoriFinishPeriodic'
  call getchar()
  redraw
  echo ''
endfunction

function! s:periodic_sh(time)
  if s:run_periodic_sh
    echo 'periodic is running'
    return
  endif
  let s:run_periodic_sh = 1
  call s:preproc_periodic()
  let cmdfile = s:path . '/../bin/periodic.sh'
  let id = matchstr(system('xdotool getactivewindow'), '\d\+')
  let geometry = s:measure_geometry()
  let temp = expand(g:komadori_temp_dir)
  let s:kom = vimproc#popen2(['sh', cmdfile, a:time, temp, id, geometry])
endfunction

function! s:periodic_py(time)
  if s:run_periodic_py
    echo 'periodic is running'
    return
  endif
  let s:run_periodic_py = 1
  call s:preproc_periodic()
  let temp = expand(g:komadori_temp_dir)
  if s:has_posh
    let margin = s:margin()
    let arg = { 'interval': a:time, 'temp_dir':temp, 'margin': margin, 'path': s:binpath}
  elseif s:has_magick
    let id = matchstr(system('xdotool getactivewindow'), '\d\+')
    let geometry = s:measure_geometry()
    let arg = { 'interval': a:time, 'temp_dir':temp, 'win_id': id, 'geometry': geometry}
  else
    echoerr 'can not execute periodic'
  endif
  python periodic = Periodic(vim.eval('arg'))
endfunction

function! komadori#finish_periodic()
  if s:run_periodic_sh
    call s:kom.kill(2)
    let s:run_periodic_sh = 0
  elseif s:run_periodic_py
    python periodic.finish()
    let s:run_periodic_py = 0
  endif
  let infile = expand(g:komadori_temp_dir) . 'komadori_*.gif'
  if s:has_posh && g:komadori_bundle_use_powershell
    let cnt = len(glob(infile, 0, 1))
    let s:delay = g:komadori_interval
    let s:delays = repeat(g:komadori_interval . ' ', cnt)
    call s:bundle_posh()
    echo 'create' g:komadori_save_file
  elseif s:has_magick_convert
    let cmd = ['convert', '-loop', '0', '-layers', 'optimize', '-delay', g:komadori_interval]
    let outfile = expand(g:komadori_save_file)
    call vimproc#system_bg(cmd + [infile, outfile])
    echo 'create' g:komadori_save_file
  else
    echoerr 'This plugin needs PowerShell or ImageMagick'
  endif
endfunction

function! komadori#pause_periodic()
  if s:run_periodic_py
    python periodic.pause()
  endif
endfunction

function! komadori#restart_periodic()
  if s:run_periodic_py
    python periodic.restart()
  endif
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
    echo 'create' name
    let s:delays .= s:delay . ' '
    let s:delay = g:komadori_interval
  elseif s:has_magick
    if executable('xdotool')
      if !s:captured
        let s:win_id = matchstr(system('xdotool getactivewindow'), '\d\+')
        let s:geometry = s:measure_geometry()
        let s:captured = 1
      endif
      let arg = ' -window ' . s:win_id . ' -crop ' . s:geometry
      let name = s:serialname()
      if s:has_vimproc
        call vimproc#system_bg('import -silent' . arg . vimproc#shellescape(name))
      else
        call system('import -silent' . arg . shellescape(name))
      endif
      echo 'create' name
    else
      echoerr 'This plugin needs xdotool'
    endif
  else
    echoerr 'This plugin needs PowerShell or ImageMagick'
  endif
endfunction

function! s:margin()
  return ' @(' . 
        \   g:komadori_margin_left   . ', ' .
        \   g:komadori_margin_top    . ', ' .
        \   g:komadori_margin_right  . ', ' .
        \   g:komadori_margin_bottom .
        \  ')'
endfunction

function! s:oneshot_cmd(filename)
  let fpath = s:binpath  . 'oneshot.ps1'
  let cmd = ['powershell', '-ExecutionPolicy', 'RemoteSigned', '-NoProfile', '-Command']
  let margin = s:margin()
  let save_cmd = ' | % { $_.save("' . a:filename . '")}'
  return cmd + [fpath . margin . save_cmd]
endfunction

function! s:measure_geometry()
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

function! s:serialname()
  let s:count_file_prefix += 1
  let file = printf('%skomadori_%03d.gif', g:komadori_temp_dir, s:count_file_prefix)
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
  if s:has_posh && g:komadori_bundle_use_powershell
    call s:bundle_posh()
    echo "create" g:komadori_save_file
  elseif s:has_magick_convert
    call s:bundle_magick()
    echo "create" g:komadori_save_file
  else
    echoerr 'This plugin needs PowerShell or ImageMagick'
  endif
endfunction

function! s:bundle_posh()
  let fpath = s:binpath . 'bundle.ps1'
  let cmd = 'powershell -ExecutionPolicy RemoteSigned -NoProfile -File ' . fpath
  let arg = [ expand(g:komadori_save_file) ,
        \     expand(g:komadori_temp_dir)  ]
  call vimproc#system_bg(split(cmd) + arg + split(s:delays . s:delay))
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

function! komadori#gyazo_post()
  redir => s:gyazo_post_url
    python print gyazo.post()
  redir END
endfunction

function! komadori#gyazo_url()
  return get(s:, 'gyazo_post_url', '')
endfunction

function! komadori#open_gyazo_url()
  if exists('*OpenBrowser')
    call OpenBrowser(komadori#gyazo_url())
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
