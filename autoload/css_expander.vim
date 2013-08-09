" vim:set sts=2 sw=2 tw=0 et:

scriptencoding utf-8

let s:DICT_JSON = expand('<sfile>:h:p') . '/css_expander.json'

if exists('s:DICT')
  unlet s:DICT
endif

function! s:get_dict()
  if !exists('s:DICT')
    let s:DICT = s:load_dict()
  endif
  return s:DICT
endfunction

function! s:load_dict()
  let dict = []
  let src = eval(join(readfile(s:DICT_JSON), ''))
  for key in sort(keys(src))
    let values = src[key]
    call add(dict, printf('%s: ', key))
    for value in values
      call add(dict, printf('%s: %s;', key, value))
    endfor
  endfor
  return dict
endfunction

function! css_expander#omni_complete(findstart, base)
  if a:findstart
    return css_expander#pre_search()
  else
    return css_expander#search(a:base)
  endif
endfunction

function! css_expander#pre_search()
  let lstr = getline('.')
  let cnum = col('.')
  let idx = match(lstr, '[-0-9A-Za-z_]\+\%' . cnum . 'c')
  if idx >= 0
    return idx
  else
    return -1
  endif
endfunction

function! css_expander#search(base)
  if len(a:base) == 0
    return []
  endif
  let pattern = '\v^(.{-})' . join(split(a:base, '\zs'), '(.{-})') .'(.{-})$'
  let words = filter(copy(s:get_dict()), 'match(v:val, pattern) >= 0')
  call map(words, '[ v:val, css_expander#weight(v:val, pattern) ]')
  call sort(words, 'css_expander#compare_words')
  return { 'words': map(words, 'css_expander#format_item(v:val)') }
endfunction

function! css_expander#complete_done()
  " nothing to do.
endfunction

function! css_expander#weight(word, pattern)
  let matches = matchlist(a:word, a:pattern)
  call remove(matches, 0)
  let weight = 0
  for ix in range(5)
    let curr = ix < len(matches) ? len(matches[ix]) : 0
    let weight = weight * 10 + (curr < 10 ? curr : 9)
  endfor
  return weight
endfunction

function! css_expander#compare_words(item1, item2)
  return a:item1[1] - a:item2[1]
endfunction

function! css_expander#format_item(item)
  return { 'word': a:item[0] }
endfunction


"===========================================================================
" Dictionary Operations

function! css_expander#dict_reload()
  let s:DICT = s:load_dict()
endfunction

function! css_expander#dict_dump()
  call append(line('.'), s:get_dict())
endfunction

function! css_expander#dict_get()
  return s:get_dict()
endfunction
