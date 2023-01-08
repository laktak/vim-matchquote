scriptencoding utf-8

if exists("g:loaded_matchquote") || &cp
  finish
endif
let g:loaded_matchquote = 1

let s:quotes = ['"', '''', '`', '|']

function! s:matchquote(mode)
  normal! m'

  if a:mode == 'x'
    normal! gv
  endif
  let c = s:character_at_cursor()
  execute "normal! \<Esc>"

  if index(s:quotes, c) == -1
    call s:fallback_to_original(a:mode)
    return
  endif

  let num = len(split(getline('.'), c, 1)) - 1
  if num % 2 == 1
    return
  endif

  " is quotation mark under cursor odd or even?
  let col = getpos('.')[2]
  let num = len(split(getline('.')[0:col-1], c, 1)) - 1

  let mvmt = num % 2 == 0 ? 'F' : 'f'
  execute 'normal!' a:mode == 'n' ? mvmt.c : mvmt.c.'m>gv'
endfunction


function! s:fallback_to_original(mode)
  if a:mode == 'n'
    execute "normal \<Plug>(MatchitNormalForward)"
  else
    execute "normal gv\<Plug>(MatchitVisualForward)"
  endif
endfunction


" Capture character under cursor in a way that works with multi-byte
" characters.  Credit to http://stackoverflow.com/a/23323958/151007.
function! s:character_at_cursor()
  return matchstr(getline('.'), '\%'.col('.').'c.')
endfunction

nnoremap <silent> <Plug>(MatchitQuoteN)     :<C-U>call <SID>matchquote('n')<CR>
nnoremap <silent> <Plug>(MatchitQuoteX)     :<C-U>call <SID>matchquote('x')<CR>

if !exists("g:no_plugin_maps")
  nnoremap <silent> <expr> % (v:count == 0 ? ":call <SID>matchquote('n')<CR>" : '%')
  xnoremap <silent> % :<C-U>call <SID>matchquote('x')<CR>
  onoremap <silent> % :normal v%<CR>

  if empty(maparg('i<Bar>', 'x')) && empty(maparg('a<Bar>', 'x'))
    xnoremap i<Bar> :<C-U>normal! T<Bar>vt<Bar><CR>
    onoremap i<Bar> :normal vi<Bar><CR>
    xnoremap a<Bar> :<C-U>normal! F<Bar>vf<Bar><CR>
    onoremap a<Bar> :normal va<Bar><CR>
  endif
endif
