let s:save_cpo = &cpo
set cpo&vim

let s:path = expand('<sfile>:p:h')
let s:started = 0

function! komadori#oneshot()
  call komadori#start()
  while komadori#read() != "start"
  endwhile
  call komadori#capture()
  call komadori#stop()
  echo "komadori one shot"
endfunction

function! komadori#insert()
  augroup PluginKomadori
    autocmd!
    autocmd CursorMovedI * call komadori#capture()
    autocmd InsertLeave * call komadori#stop() | echo "komadori stop!"
  augroup END
  call komadori#start()
  echo "komadori start!"
  call getchar()
  startinsert
endfunction

function! komadori#periodic(time)
  let save_pd = g:komadori_periodic
  let g:komadori_periodic = a:time
  echo "komadori ready"
  call komadori#start()
  while komadori#read() != "start"
  endwhile
  echo "start"
  let g:komadori_periodic = save_pd
endfunction

function! komadori#start()
  if s:started
    echo "already start komadori"
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

function! komadori#stop()
  augroup PluginKomadori
    autocmd!
  augroup END
  if !s:started
    return
  endif
  let s:started = 0
  call s:kom.stdin.write("quit\n")
  "call s:kom.waitpid()
endfunction

function! komadori#capture()
  call komadori#write("cap")
endfunction

function! komadori#keep()
  call komadori#write("keep")
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

let &cpo = s:save_cpo
unlet s:save_cpo

