let s:save_cpo = &cpo
set cpo&vim

let s:path = expand('<sfile>:p:h')
let s:binpath = s:path . '\..\..\bin\'
let s:has_posh = executable('powershell')
let s:has_magick = executable('import')
let s:has_vimproc = 0
silent! let s:has_vimproc = vimproc#version()
let s:run_periodic_sh = 0
let s:run_periodic_py = 0

python <<EOM
import os.path, sys, vim
binpath = os.path.join(vim.eval('s:path'), '..', '..', 'bin')
if not binpath in sys.path:
  sys.path.append(binpath)
EOM
python from periodic import Periodic

function! komadori#periodic#start(time)
  if s:has_posh
    if has('python') && g:komadori_use_python
      call s:do_py(a:time)
      python periodic.runWith('posh')
    else
      call s:do_posh(a:time)
    endif
  elseif s:has_magick
    if s:has_vimproc && executable('xdotool')
      if has('python') && g:komadori_use_python
        call s:do_py(a:time)
        python periodic.runWith('magick')
      else
        call s:do_sh(a:time)
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

function! s:preprocess()
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

function! s:do_sh(time)
  if s:run_periodic_sh
    echo 'periodic is running'
    return
  endif
  let s:run_periodic_sh = 1
  call s:preprocess()
  let cmdfile = s:path . '/../bin/periodic.sh'
  let id = matchstr(system('xdotool getactivewindow'), '\d\+')
  let geometry = komadori#internal#measure_geometry()
  let temp = expand(g:komadori_temp_dir)
  let s:kom = vimproc#popen2(['sh', cmdfile, a:time, temp, id, geometry])
endfunction

function! s:do_py(time)
  if s:run_periodic_py
    echo 'periodic is running'
    return
  endif
  let s:run_periodic_py = 1
  call s:preprocess()
  let temp = expand(g:komadori_temp_dir)
  if s:has_posh
    let margin = komadori#internal#margin()
    let arg = { 'interval': a:time, 'temp_dir':temp, 'margin': margin, 'path': s:binpath}
  elseif s:has_magick
    let id = matchstr(system('xdotool getactivewindow'), '\d\+')
    let geometry = komadori#internal#measure_geometry()
    let arg = { 'interval': a:time, 'temp_dir':temp, 'win_id': id, 'geometry': geometry}
  else
    echoerr 'can not execute periodic'
  endif
  python periodic = Periodic(vim.eval('arg'))
endfunction

function! komadori#periodic#finish()
  if s:run_periodic_sh
    call s:kom.kill(2)
    let s:run_periodic_sh = 0
  elseif s:run_periodic_py
    python periodic.finish()
    let s:run_periodic_py = 0
  endif
  call komadori#all_bundle()
endfunction

function! komadori#periodic#pause()
  if s:run_periodic_py
    python periodic.pause()
  endif
endfunction

function! komadori#periodic#restart()
  if s:run_periodic_py
    python periodic.restart()
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
