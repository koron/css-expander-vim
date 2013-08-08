" vim:set sts=2 sw=2 tw=0 et:

let b:css_expander_loaded = strftime('%c')

setlocal omnifunc=css_expander#omni_complete

augroup css_expander
  autocmd!
  autocmd CompleteDone <buffer> call css_expander#complete_done()
augroup END
