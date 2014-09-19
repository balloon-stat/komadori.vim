let s:save_cpo = &cpo
set cpo&vim

let s:path = expand('<sfile>:p:h')
python <<EOM
import os.path, sys, vim
binpath = os.path.join(vim.eval('s:path'), '..', '..', 'bin')
if not binpath in sys.path:
  sys.path.append(binpath)
EOM
python import gyazo

function! komadori#gyazo#post()
  redir => s:gyazo_post_url
    python print gyazo.post()
  redir END
endfunction

function! komadori#gyazo#url()
  return get(s:, 'gyazo_post_url', '')
endfunction

function! komadori#gyazo#open_url()
  if exists('*OpenBrowser')
    call OpenBrowser(komadori#gyazo#url())
  endif
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
