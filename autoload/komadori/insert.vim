let s:save_cpo = &cpo
set cpo&vim

function! komadori#insert#start()
  augroup PluginKomadori
    autocmd!
    autocmd CursorMovedI * silent call komadori#capture()
    autocmd InsertLeave * call komadori#insert#finish()
  augroup END
  echo 'komadori start!'
  call getchar()
  startinsert
endfunction

function! komadori#insert#finish()
  augroup PluginKomadori
    autocmd!
  augroup END
  call komadori#bundle()
  echo 'komadori stop!'
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
