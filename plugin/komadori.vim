if exists('g:loaded_komadori')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=1 ComadoriStartPeriodic  call komadori#periodic(<q-args>)
command! -nargs=0 ComadoriFinishPeriodic call komadori#finish_periodic()
command! -nargs=0 ComadoriCapture        call komadori#capture()
command! -nargs=0 ComadoriBundle         call komadori#bundle()
command! -nargs=0 ComadoriInsert         call komadori#insert()
command! -nargs=0 ComadoriGyazoPost      call komadori#gyazo_post()
command! -nargs=0 ComadoriYankGyazoUrl   call setreg(v:register == "" ? '"' : v:register, komadori#gyazo_url())
command! -nargs=0 ComadoriOpenGyazoUrl   call komadori#open_gyazo_url()

nnoremap <Plug>(komadori-capture)          :<C-u>call komadori#capture()<CR>
nnoremap <Plug>(komadori-bundle)           :<C-u>call komadori#bundle()<CR>
nnoremap <Plug>(komadori-keep)             :<C-u>call komadori#keep()<CR>
nnoremap <Plug>(komadori-pause-periodic)   :<C-u>call komadori#pause_periodic()<CR>
nnoremap <Plug>(komadori-restart-periodic) :<C-u>call komadori#restart_periodic()<CR>
nnoremap <Plug>(komadori-finish-periodic)  :<C-u>call komadori#finish_periodic()<CR>

let g:komadori_save_file      = get(g:, 'komadori_save_file', '~/vim.gif')
let g:komadori_temp_dir       = get(g:, 'komadori_temp_dir', '~/')
let g:komadori_interval       = get(g:, 'komadori_interval', 40)
let g:komadori_use_python     = get(g:, 'komadori_use_python', 1)
let g:komadori_use_powershell = get(g:, 'komadori_use_powershell', 1)

if has('win32')
  let g:komadori_margin_left   = get(g:, 'komadori_margin_left', 8)
  let g:komadori_margin_top    = get(g:, 'komadori_margin_top', 100)
  let g:komadori_margin_right  = get(g:, 'komadori_margin_right', 8)
  let g:komadori_margin_bottom = get(g:, 'komadori_margin_bottom', 8)
else
  let g:komadori_margin_left   = get(g:, 'komadori_margin_left', 0)
  let g:komadori_margin_top    = get(g:, 'komadori_margin_top', 0)
  let g:komadori_margin_right  = get(g:, 'komadori_margin_right', 0)
  let g:komadori_margin_bottom = get(g:, 'komadori_margin_bottom', 0)
endif

let g:loaded_komadori = 1

let &cpo = s:save_cpo
unlet s:save_cpo
