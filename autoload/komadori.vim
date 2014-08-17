let s:save_cpo = &cpo
set cpo&vim

let s:path = expand('<sfile>:p:h')
let s:started = 0
let s:has_posh = executable('powershell')
let s:has_magick = executable('import')
let s:count_file_prefix = 0

function! komadori#oneshot()
  call komadori#capture()
  call komadori#bundle()
  echo 'komadori one shot'
endfunction

function! komadori#insert()
  augroup PluginKomadori
    autocmd!
    autocmd CursorMovedI * call komadori#capture()
    autocmd InsertLeave * call komadori#bundle() | echo 'komadori stop!'
  augroup END
  call komadori#ready()
  echo 'komadori start!'
  call getchar()
  startinsert
endfunction

function! komadori#periodic(time)
  if !s:has_posh
    echoerr 'This method needs PowerShell'
    return
  end
  let save_pd = g:komadori_periodic
  let g:komadori_periodic = a:time
  echo 'komadori ready'
  call komadori#ready()
  while komadori#read() != 'start'
  endwhile
  echo 'start'
  let g:komadori_periodic = save_pd
endfunction

function! komadori#ready()
  if !s:has_posh
    return
  end
  if s:started
    echo 'already start komadori'
    return
  endif
  let s:started = 1
  let fpath = vimproc#shellescape(s:path  . '\..\bin\komadori.ps1')
  let cmd = 'powershell -ExecutionPolicy RemoteSigned -File ' . fpath
  let far = ' -filename '      . vimproc#shellescape(expand(g:komadori_save_file))
  let par = ' -periodic '      . g:komadori_periodic
  let iar = ' -interval '      . g:komadori_interval
  let lar = ' -margin_left '   . g:komadori_margin_left
  let tar = ' -margin_top '    . g:komadori_margin_top
  let rar = ' -margin_right '  . g:komadori_margin_right
  let bar = ' -margin_bottom ' . g:komadori_margin_bottom
  let arg = far . par . iar . lar . tar . rar . bar
  let s:kom = vimproc#popen2(cmd . arg)
  "call vimproc#system_gui(cmd . arg)
endfunction

function! komadori#bundle()
  augroup PluginKomadori
    autocmd!
  augroup END
  if !s:started
    return
  endif
  let s:started = 0
  if s:has_posh
    call s:kom.stdin.write("quit\n")
    "call s:kom.waitpid()
  elseif s:has_magick
    let cmd = 'convert -loop 0 -layers optimize -delay `=g:komadori_interval`'
    let max = s:count_file_prefix
    let s:count_file_prefix = 0
    let infile = ''
    for i in range(1, max)
      let infile .= ' ' . shellescape(serialname())
    endfor
    let s:count_file_prefix = 0
    aklf
    call system(cmd . infile . ' ' . shellescape(g:komadori_save_file))
    !rm komadori_*.gif
  endif
endfunction

function! komadori#capture()
  if s:has_posh
    if !s:started
      call komadori#ready()
      while komadori#read() != "start"
      endwhile
    endif
    call komadori#write("cap")
  elseif s:has_magick
    if !s:started
      call s:set_geometry
      let s:started = 1
    endif
    let cmd = 'import -crop ' . s:geometry . ' ' . shellescape(s:serialname())
    call system(cmd)
  else
    echoerr 'This plugin needs PowerShell or ImageMagick'
  endif
endfunction

function! s:set_geometry()
  if executable('xdotool')
    let geoinfo = vimproc#system('xwininfo -id `xdotool getactivewindow`')
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
    let s:geometry = width . 'x' . height . x . y
  else
    echoerr 'This plugin needs xdotool'
  endif
endfunction

function! s:serialname()
  let s:count_file_prefix += 1
  let file = g:komadori_temp_dir . 'komadori_' . s:count_file_prefix . '.gif'
  return expand(file)
endfunction

function! komadori#keep()
  if s:has_posh
    call komadori#write("keep")
  else
    echoerr 'This method is used in Windows'
  endif
endfunction

function! komadori#read()
  if !s:started
    echo "not start komadori"
    return
  endif
  echo s:kom.stdout.read()
endfunction

function! komadori#write(arg)
  if !s:started
    echo "not start komadori"
    return
  endif
  call s:kom.stdin.write(a:arg . "\n")
endfunction

unlet s:save_cpo

