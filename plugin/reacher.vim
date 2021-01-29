if exists('g:loaded_reacher')
    finish
endif
let g:loaded_reacher = 1

command! -nargs=* Reacher lua require("reacher.command").main(<f-args>)

if get(g:, 'reacher_debug', v:false)
    augroup reacher_dev
        autocmd!
        execute 'autocmd BufWritePost' expand('<sfile>:p:h:h') .. '/*' 'lua require("reacher.lib.module").cleanup()'
    augroup END
endif
