# reacher.nvim

This plugin introduces displayed range search buffer.

## Usage

```vim
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

  inoremap <buffer> <CR> <Cmd>lua require("reacher").finish()<CR>
  inoremap <buffer> <ESC> <Cmd>lua require("reacher").cancel()<CR>
  inoremap <buffer> <Tab> <Cmd>lua require("reacher").next()<CR>
  inoremap <buffer> <S-Tab> <Cmd>lua require("reacher").previous()<CR>
  inoremap <buffer> <C-n> <Cmd>lua require("reacher").forward_history()<CR>
  inoremap <buffer> <C-p> <Cmd>lua require("reacher").backward_history()<CR>

  nnoremap <buffer> <CR> <Cmd>lua require("reacher").finish()<CR>
  nnoremap <nowait> <buffer> <ESC> <Cmd>lua require("reacher").cancel()<CR>
  nnoremap <buffer> gg <Cmd>lua require("reacher").first()<CR>
  nnoremap <buffer> G <Cmd>lua require("reacher").last()<CR>
  nnoremap <buffer> j <Cmd>lua require("reacher").next()<CR>
  nnoremap <buffer> k <Cmd>lua require("reacher").previous()<CR>
  nnoremap <buffer> l <Cmd>lua require("reacher").side_next()<CR>
  nnoremap <buffer> h <Cmd>lua require("reacher").side_previous()<CR>
endfunction
```