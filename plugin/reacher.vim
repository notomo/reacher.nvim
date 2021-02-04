if exists('g:loaded_reacher')
    finish
endif
let g:loaded_reacher = 1

if get(g:, 'reacher_debug', v:false)
    augroup reacher_dev
        autocmd!
        execute 'autocmd BufWritePost' expand('<sfile>:p:h:h:gs?\?\/?') .. '/lua/*' 'lua require("reacher.lib.module").cleanup()'
    augroup END
endif
