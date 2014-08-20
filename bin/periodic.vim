
let s:count_file_prefix = 0

function! Capture()
  let s:count_file_prefix += 1
  let file = g:komadori_temp_dir . 'komadori_' . s:count_file_prefix . '.gif'
  let name = expand(file)
  let arg = ' -window ' . s:win_id . s:geometry
  call vimproc#system_bg('import -silent' . arg . vimproc#shellescape(name))
endfunction

function! SettingKomadori(time, temp, id, geometry)
  let &updatetime = a:time
  let s:temp_dir = a:temp
  let s:win_id = a:id
  let s:geometry = a:geometry
  augroup PluginKomadori
    autocmd!
    autocmd CursorHold * silent call feedkeys("g\<ESC>", 'n')
    autocmd CursorHold * call Capture()
  augroup END
endfunction
