nnoremap gs <Cmd>lua require("reacher").start()<CR>
xnoremap gs <Cmd>lua require("reacher").start()<CR>

augroup reacher_setting
  autocmd!
  autocmd Filetype reacher call s:reacher()
augroup END
function! s:reacher() abort
  " default mappings

  " {mappings}
endfunction
