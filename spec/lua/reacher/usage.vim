nnoremap gs <Cmd>lua require("reacher").start()<CR>
xnoremap gs <Cmd>lua require("reacher").start()<CR>

" search current line
nnoremap gl <Cmd>lua require("reacher").start({
  \ first_row = vim.fn.line("."),
  \ last_row = vim.fn.line(".")
\ })<CR>

augroup reacher_setting
  autocmd!
  autocmd Filetype reacher call s:reacher()
augroup END
function! s:reacher() abort
  " default mappings

  " {mappings}
endfunction
