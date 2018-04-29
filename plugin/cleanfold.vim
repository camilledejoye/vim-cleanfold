if exists('g:cleanfold_loaded') && g:cleanfold_loaded
  finish
endif
let g:cleanfold_loaded = 1

let s:cpo_save = &cpo
set cpo&vim

set foldtext=MyFoldText()

" Global Scope {{{
" configuration {{{
if !exists('g:cleanfold_remove_markers')
  let g:cleanfold_remove_markers = 1
endif

if !exists('g:cleanfold_fillchar')
  let g:cleanfold_fillchar = get(g:, 'cleanfold_fillchar', ' ')
endif

if !exists('g:cleanfold_handlers')
  let g:cleanfold_handlers = ['s:MultilineCommentFoldHandler']
endif
" }}}

" Functions {{{
function! MyFoldText() " {{{
  try
    let l:firstline           = getline(v:foldstart)
    let l:space_available     = winwidth(0) - s:GetLeftColumnWidth()

    let l:folded_lines_counter  = ' ' . s:GetFoldedLinesCounter()
    let l:space_available      -= strwidth(l:folded_lines_counter)
    let l:foldtext              = s:GetFoldedText() . ' '

    if l:space_available < strwidth(l:foldtext)
      let l:foldtext = strpart(l:foldtext, 0, l:space_available) " Shrink to fit in the window
    endif

    let l:space_available -= strwidth(l:foldtext)

    let l:foldtext .= repeat(s:GetFillChar(), l:space_available) . l:folded_lines_counter
  catch
    echoerr v:exception
    let l:foldtext = foldtext()
  endtry

  return l:foldtext
endfunction " }}}
" }}}

" Commands {{{
command! -nargs=1 ChangeFoldFillChar call <SID>ChangeFillChar(<f-args>)
" }}}
" }}}

" Script Functions {{{
function! s:MultilineCommentFoldHandler() " {{{
  for l:comment_start in s:GetMultilineCommentStarts()
    if getline(v:foldstart) =~ '^\s*' . s:EscapePattern(l:comment_start)
      return s:MultiLinesComment(l:comment_start)
    endif
  endfor
endfunction " }}}

function! s:GetFoldedText() " {{{
  for l:function_name in g:cleanfold_handlers
    let l:foldtext = call(l:function_name, [])

    if !empty(l:foldtext)
      return s:RemoveMarkers(l:foldtext)
    endif
  endfor

  return s:RemoveMarkers(getline(v:foldstart))
endfunction " }}}

function! s:GetFoldedLinesCounter() " {{{
  return printf(
    \'%*d lines +%s',
    \ s:GetNumberWidth(),
    \ v:foldend - v:foldstart + 1,
    \ v:folddashes
  \)
endfunction " }}}

function! s:MultiLinesComment(comment_start) " {{{
  let l:escaped_comment_start  = s:EscapePattern(a:comment_start)
  let l:escaped_comment_middle = s:EscapePattern(substitute(
    \ &comments,
    \ 's[^:]*:' . l:escaped_comment_start . ',m[^:]*:\([^,]\+\).*',
    \ '\1',
    \ ''
    \))
  if '/*' == a:comment_start
    let l:escaped_comment_start .= '\{1,2}' " hack for comment doc
  endif

  let l:comment_type = substitute(
    \ getline(v:foldstart),
    \ '^\(\s*' . l:escaped_comment_start . '\).*',
    \ '\1',
    \ ''
  \)
  let l:text = s:FindFirstNonBlankLine(
    \ '\%(' . l:escaped_comment_start . '\|' . l:escaped_comment_middle . '\)'
  \)

  return printf('%s %s', l:comment_type, l:text)
endfunction " }}}

function! s:FindFirstNonBlankLine(...) " {{{
" Argument: if provided a:1 is a pattern that represent something to ignore

  let l:pattern = printf('^\s*%s\(.\{-}\)\s*$', a:0 ? a:1 . '\s*' : '')

  " Find the first non empty line and trim the content
  for l:linenr in range(v:foldstart, v:foldend)
    let l:line = s:RemoveMarkers(getline(l:linenr))

    let l:content = substitute(l:line, l:pattern, '\1', '')

    if !empty(l:content)
      return l:content
    endif
  endfor

  return ''
endfunction " }}}

function! s:GetMultilineCommentStarts() " {{{
  return map(
    \ filter(split(&comments, ','), 'v:val =~ "^s"'),
    \ {key, val -> substitute(val, '[^:]\+:', '', '')}
  \)
endfunction " }}}

function! s:EscapePattern(pattern, ...) " {{{
  " a:1 optional : the delimiter use for the pattern
  let l:delimiter = a:0 ? a:1 : '/'

  return escape(a:pattern, '\$^.*~[' . l:delimiter)
endfunction " }}}

function! s:ShouldHandleMarkers() " {{{
  return get(b:, 'cleanfold_remove_markers', g:cleanfold_remove_markers)
        \ && &foldmethod == 'marker'
endfunction " }}}

function! s:RemoveMarkers(string) " {{{
  if !s:ShouldHandleMarkers()
    return a:string
  endif

  let l:marker_pattern = '\(' . printf(
    \ s:EscapePattern(&commentstring),
    \ '\)\?\s*' . s:EscapePattern(get(split(&foldmarker, ','), 0)) . '\d*\s*'
  \)

  return substitute(a:string, l:marker_pattern, '', '')
endfunction " }}}

function! s:GetNumberWidth() " {{{
  return max([strwidth(line('$') + 1), v:version < 701 ? 4 : &numberwidth])
endfunction " }}}

function! s:GetLeftColumnWidth() " {{{
  let l:sign_column_activated = &signcolumn != 'no'

  return &number * s:GetNumberWidth() + &foldcolumn + 2 * s:IsSignColumnActivated()
endfunction " }}}

function! s:IsSignColumnActivated() " {{{
  let l:signs = ''

  redir => l:signs
  execute 'silent sign place file=' . expand('%')
  redir END

  return l:signs =~ 'line='
endfunction " }}}

function! s:GetFillChar() " {{{
  return matchstr(&fillchars, 'fold:\zs.')
endfunction " }}}

function! s:ChangeFillChar(char) " {{{
  let l:old_fillchar = s:GetFillChar()

  let &fillchars = substitute(&fillchars, 'fold:\zs.', a:char, '')

  return l:old_fillchar
endfunction " }}}
" }}}

if exists('g:cleanfold_fillchar')
  call s:ChangeFillChar(g:cleanfold_fillchar)
endif

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: et sw=2 ts=2 fdm=marker
