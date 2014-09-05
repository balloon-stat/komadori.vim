let s:save_cpo = &cpo
set cpo&vim

function! komadori#cmdlist#start()
  let s:lnum = 0
  wincmd p
  let line = getline(1)
  wincmd p
  if line != 'cmdlist'
    echo 'no cmdlist'
    return
  endif
  let s:blink_off = has('gui') && g:komadori_cursor_blink_control
  if s:blink_off
    set guicursor+=a:blinkon0
  endif
  echo ""
  augroup PluginKomadori
    autocmd!
    autocmd CursorHold * call feedkeys("g\<ESC>", "n")
    autocmd CursorHold * call <SID>step()
  augroup END
endfunction

function! s:step()
  let s:lnum += 1
  wincmd p
  if s:lnum > line('$')
    call s:clear()
    silent call komadori#bundle()
    match
    wincmd p
    return
  endif
  if s:lnum == 1
    normal gg
    wincmd p
    return
  else
    normal j
  endif
  let line = getline(s:lnum)
  execute 'match Search /\%' . s:lnum . 'l/'
  wincmd p
  if line[0] == ''
    " nop
  elseif line[0] == ':'
    execute line[1:]
  else
    execute 'normal' line
  endif
  silent call komadori#capture()
endfunction

function! s:clear()
  augroup PluginKomadori
    autocmd!
  augroup END
  if s:blink_off
    set guicursor-=a:blinkon0
  endif
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
