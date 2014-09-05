let s:save_cpo = &cpo
set cpo&vim

let s:path = expand('<sfile>:p:h')
let s:binpath = s:path . '\..\bin\'
let s:captured = 0
let s:has_posh = executable('powershell')
let s:has_magick = executable('import')
let s:has_magick_convert = executable('convert')
let s:has_vimproc = 0
silent! let s:has_vimproc = vimproc#version()

python <<EOM
import os.path, sys, vim
binpath = os.path.join(vim.eval('s:path'), '..', 'bin')
if not binpath in sys.path:
  sys.path.append(binpath)
EOM

function! komadori#all_bundle()
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

function! komadori#capture()
  if s:has_posh
    if !s:captured
      let s:delays = ''
      let s:delay = g:komadori_interval
      let s:captured = 1
    endif
    let name = komadori#internal#serialname()
    call vimproc#system_bg(s:oneshot_cmd(name))
    echo 'create' name
    let s:delays .= s:delay . ' '
    let s:delay = g:komadori_interval
  elseif s:has_magick
    if executable('xdotool')
      if !s:captured
        let s:win_id = matchstr(system('xdotool getactivewindow'), '\d\+')
        let s:geometry = komadori#internal#measure_geometry()
        let s:captured = 1
      endif
      let arg = ' -window ' . s:win_id . ' -crop ' . s:geometry
      let name = komadori#internal#serialname()
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

function! s:oneshot_cmd(filename)
  let fpath = s:binpath  . 'oneshot.ps1'
  let cmd = ['powershell', '-ExecutionPolicy', 'RemoteSigned', '-NoProfile', '-Command']
  let margin = komadori#internal#margin()
  let save_cmd = ' | % { $_.save("' . a:filename . '")}'
  return cmd + [fpath . margin . save_cmd]
endfunction

function! komadori#bundle()
  if !s:captured
    echo 'no capture'
    return
  endif
  if s:has_posh && g:komadori_bundle_use_powershell
    call s:bundle_posh()
    echo "create" g:komadori_save_file "by powershell"
  elseif s:has_magick_convert
    call s:bundle_magick()
    echo "create" g:komadori_save_file "by convert"
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
  call komadori#internal#reset_count()
endfunction

function! s:bundle_magick()
  let cmd = 'convert -loop 0 -layers optimize -delay ' . g:komadori_interval
  let max = komadori#internal#prefix_count()
  call komadori#internal#reset_count()
  let infile = ''
  for i in range(1, max)
    let infile .= ' ' . shellescape(komadori#internal#serialname())
  endfor
  call komadori#internal#reset_count()
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
