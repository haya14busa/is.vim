"=============================================================================
" FILE: autoload/is.vim
" AUTHOR: haya14busa
" License: MIT license
"=============================================================================
scriptencoding utf-8

let s:DIRECTION = { 'FORWARD': 1, 'BACKWARD': 0 }

function! is#scroll(dir) abort
  let next_cmd = a:dir == s:DIRECTION.FORWARD ? "\<C-g>" : "\<C-t>"
  let prev_cmd = a:dir == s:DIRECTION.FORWARD ? "\<C-t>" : "\<C-g>"
  let [pattern, offset] = s:parse_search_cmdline(getcmdline(), getcmdtype())
  if offset !=# ''
    return ''
  endif
  let cnts = s:rich_count(a:dir, pattern)
  return repeat(next_cmd, cnts.next) . repeat(prev_cmd, cnts.prev)
endfunction

" s:rich_count returns the count of next and prev commands to be executed.
" Since, we cannot control the view of the current window to put cursor
" position at the top, bottom or middle of windows while incremental
" searching by winsaveview() or normal!, move over destination and return to
" the target position by prev count.
"
" @return { 'next': <number>, 'prev': <number> }
"
" Cursor Position: `|`
"
" Step 0: Original state.
" Step 1:
"   - Move cursor to pattern5 while target is pattern3 by <C-g> (next cmd).
"   - Curor is at the *bottom* of the window (by moving cursor by <C-g>).
"   - Note that if the cursor is at the bottom, next is#scroll() is not
"     effective since cursor is already at the bottom and next is#scroll() will
"     just move cursor the next match.
" Step 2:
"   - Move cursor to the target(pattern3) by <C-t> (prev cmd)
"   - Curor is at the *top* of the window (by moving cursor by <C-g>).
"
" Step 0:                Step 1:                  Step 2:
"   === BUFFER ====        === BUFFER ====          === BUFFER ====
"
"   --- Window ---          pattern1                 pattern1
"   |pattern1
"                           pattern2                 pattern2
"    pattern2
"   --- /Window ---         pattern3 <- target      --- Window ---
"    pattern3 <- target                             |pattern3 <- target
"                          --- Window ---
"    pattern4               pattern4                 pattern4
"                                                   --- /Window ---
"    pattern5              |pattern5
"                          --- /Window ---           pattern5
"
"    pattern6               pattern6                 pattern6
"   ===============        ==============           ==============
function! s:rich_count(dir, pattern) abort
  let first = s:scroll_move_and_count(a:dir, a:pattern)
  if a:dir == s:DIRECTION.FORWARD
    call s:zt()
  else
    call s:zb()
  endif
  let second = s:scroll_move_and_count(a:dir, a:pattern)
  return { 'next': first + second, 'prev': second }
endfunction

function! s:zt() abort
  call winrestview({'topline': line('.')})
endfunction

function! s:zb() abort
  call winrestview({'topline': max([1, line('.') - winheight(0)])})
endfunction

function! is#scroll_count(dir, pattern) abort
  let save_win = winsaveview()
  let cnt = s:scroll_move_and_count(a:dir, a:pattern)
  call winrestview(save_win)
  return cnt
endfunction

function! s:scroll_move_and_count(dir, pattern) abort
  let flags = a:dir == s:DIRECTION.FORWARD ? '' : 'b'
  let stopline = a:dir == s:DIRECTION.FORWARD ? line('w$') : line('w0')
  let cnt = 1
  if a:dir == s:DIRECTION.BACKWARD
    " Cursor is at the end of match while forward incremental searching.
    " Decrement count in such case.
    if searchpos(a:pattern, 'ncb', line('.')) != getcurpos()[1:2]
      let cnt -= 1
    endif
  endif
  " Count up until cursor moves to the match at the edge of window.
  while 1
    let [line, col] = searchpos(a:pattern, flags, stopline)
    if [line, col] == [0, 0]
      break
    endif
    let cnt += 1
  endwhile
  " Find a match in outside window.
  let pos = searchpos(a:pattern, flags, 0)
  if pos == [0, 0]
    return 0
  endif
  return cnt
endfunction

" @return [pattern, offset]
function! s:parse_search_cmdline(expr, search_key) abort
  " search_key : '/' or '?'
  " expr       : {pattern\/pattern}/{offset}
  " expr       : {pattern}/;/{newpattern} :h //;
  " return     : [{pattern\/pattern}, {offset}]
  let very_magic = '\v'
  let pattern  = '(%(\\.|.){-})'
  let slash = '(\' . a:search_key . '&[^\\"|[:alnum:][:blank:]])'
  let offset = '(.*)'

  let parse_pattern = very_magic . pattern . '%(' . slash . offset . ')?$'
  let result = matchlist(a:expr, parse_pattern)[1:3]
  if type(result) == type(0) || empty(result)
    return []
  endif
  unlet result[1]
  return result
endfunction

" Make sure move cursor by search related action __after__ calling this
" function because the first move event just set nested autocmd which
" does :nohlsearch
" @expr
function! is#auto_nohlsearch(after_n_moves) abort
  call s:auto_nohlsearch(a:after_n_moves)
  return ''
endfunction

noremap  <silent><expr> <Plug>(_is-nohlsearch) is#auto_nohlsearch(1)
noremap! <silent><expr> <Plug>(_is-nohlsearch) is#auto_nohlsearch(1)
nnoremap <silent>       <Plug>(_is-nohlsearch) :<C-u>nohlsearch<CR>
xnoremap <silent>       <Plug>(_is-nohlsearch) :<C-u>nohlsearch<CR>gv

function! s:auto_nohlsearch(after_n_moves) abort
  " NOTE: :h autocmd-searchpat
  "   You cannot implement this feature without feedkeys() because of
  "   :h autocmd-searchpat
  augroup plugin-is-auto-nohlsearch-internal
    autocmd!
    autocmd InsertEnter * :call <SID>attach_on_insert_leave() |
    \                     autocmd! plugin-is-auto-nohlsearch-internal
    execute join([
    \   'autocmd CursorMoved *'
    \ , repeat('autocmd plugin-is-auto-nohlsearch-internal CursorMoved * ', a:after_n_moves - 1)
    \ , 'call feedkeys("\<Plug>(_is-nohlsearch)", "m")'
    \ , '| autocmd! plugin-is-auto-nohlsearch-internal'
    \ ], ' ')
  augroup END
endfunction

function! s:attach_on_insert_leave() abort
  augroup plugin-is-auto-nohlsearch-internal-on-insert-leave
    autocmd!
    autocmd InsertLeave * :call is#auto_nohlsearch(1)
    \ | autocmd! plugin-is-auto-nohlsearch-internal-on-insert-leave
  augroup END
endfunction

" __END__
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
