"=============================================================================
" FILE: plugin/is.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8
if expand('%:p') ==# expand('<sfile>:p')
  unlet! g:loaded_is
endif
if exists('g:loaded_is')
  finish
endif
let g:loaded_is = 1

function! s:is_search() abort
  return getcmdtype() =~# '[/\?]'
endfunction

cnoremap <expr> <Plug>(is-scroll-f) <SID>is_search() ? is#scroll(1) : ''
cnoremap <expr> <Plug>(is-scroll-b) <SID>is_search() ? is#scroll(0) : ''
noremap  <expr> <Plug>(is-scroll-f) is#scroll_count(1, @/) . 'nzz'
noremap  <expr> <Plug>(is-scroll-b) is#scroll_count(0, @/) . 'Nzz'

" Execute :nohlsearch after one cursor move or other autocmd events.
noremap <expr> <Plug>(is-nohl-1) is#auto_nohlsearch(1)
noremap <expr> <Plug>(is-nohl-2) is#auto_nohlsearch(2)
noremap <expr> <Plug>(is-nohl-3) is#auto_nohlsearch(3)

map <Plug>(is-nohl) <Plug>(is-nohl-2)

" To avoid recursive mapping.
noremap <Plug>(_is-n)  n
noremap <Plug>(_is-N)  N
noremap <Plug>(_is-*)  *
noremap <Plug>(_is-#)  #
noremap <Plug>(_is-g*) g*
noremap <Plug>(_is-g#) g#

map <Plug>(is-n)  <Plug>(is-nohl)<Plug>(_is-n)
map <Plug>(is-N)  <Plug>(is-nohl)<Plug>(_is-N)
map <Plug>(is-*)  <Plug>(is-nohl)<Plug>(_is-*)
map <Plug>(is-#)  <Plug>(is-nohl)<Plug>(_is-#)
map <Plug>(is-g*) <Plug>(is-nohl)<Plug>(_is-g*)
map <Plug>(is-g#) <Plug>(is-nohl)<Plug>(_is-g#)

if exists('##CmdlineLeave')
  augroup plugin-is
    autocmd!
    autocmd CmdlineLeave [/\?] :call is#auto_nohlsearch(2)
  augroup END
endif

if get(g:, 'is#do_default_mappings', 1)
  if mapcheck("\<C-j>", 'c') ==# ''
    cmap <C-j> <Plug>(is-scroll-f)
  endif
  if mapcheck("\<C-k>", 'c') ==# ''
    cmap <C-k> <Plug>(is-scroll-b)
  endif
  for s:map in ['n', 'N', '*', '#', 'g*', 'g#']
    if mapcheck(s:map, 'n') ==# ''
      execute printf(':nmap %s <Plug>(is-%s)', s:map, s:map)
    endif
    if mapcheck(s:map, 'x') ==# ''
      execute printf(':xmap %s <Plug>(is-%s)', s:map, s:map)
    endif
    if mapcheck(s:map, 'o') ==# ''
      execute printf(':omap %s <Plug>(is-%s)', s:map, s:map)
    endif
  endfor
  unlet s:map
endif

" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
