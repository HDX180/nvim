scriptencoding utf-8

let s:slash = exists('+shellslash') ? '\' : '/'

function! copilot#doc#UTF16Width(str) abort
  return strchars(substitute(a:str, "\\%#=2[^\u0001-\uffff]", "  ", 'g'))
endfunction

if exists('*utf16idx')
  function! copilot#doc#UTF16ToByteIdx(str, utf16_idx) abort
    return byteidx(a:str, a:utf16_idx, 1)
  endfunction
elseif has('nvim')
  function! copilot#doc#UTF16ToByteIdx(str, utf16_idx) abort
    try
      return v:lua.vim.str_byteindex(a:str, a:utf16_idx, 1)
    catch /^Vim(return):E5108:/
      return -1
    endtry
  endfunction
else
  function! copilot#doc#UTF16ToByteIdx(str, utf16_idx) abort
    if copilot#doc#UTF16Width(a:str) < a:utf16_idx
      return -1
    endif
    let end_offset = len(a:str)
    while copilot#doc#UTF16Width(strpart(a:str, 0, end_offset)) > a:utf16_idx && end_offset > 0
      let end_offset -= 1
    endwhile
    return end_offset
  endfunction
endif


let s:language_normalization_map = {
  \ "bash":            "shellscript",
  \ "bst":             "bibtex",
  \ "cs":              "csharp",
  \ "cuda":            "cuda-cpp",
  \ "dosbatch":        "bat",
  \ "dosini":          "ini",
  \ "gitcommit":       "git-commit",
  \ "gitrebase":       "git-rebase",
  \ "make":            "makefile",
  \ "objc":            "objective-c",
  \ "objcpp":          "objective-cpp",
  \ "ps1":             "powershell",
  \ "raku":            "perl6",
  \ "sh":              "shellscript",
  \ "text":            "plaintext",
  \ }
function! copilot#doc#LanguageForFileType(filetype) abort
  let filetype = substitute(a:filetype, '\..*', '', '')
  return get(s:language_normalization_map, empty(filetype) ? "text" : filetype, filetype)
endfunction

function! s:UrlEncode(str) abort
  return substitute(iconv(a:str, 'latin1', 'utf-8'),'[^A-Za-z0-9._~!$&''()*+,;=:@/-]','\="%".printf("%02X",char2nr(submatch(0)))','g')
endfunction

let s:slash = exists('+shellslash') ? '\' : '/'
function! s:UriFromBufnr(bufnr) abort
  let absolute = tr(bufname(a:bufnr), s:slash, '/')
  if absolute !~# '^\a\+:\|^/\|^$' && getbufvar(a:bufnr, 'buftype') =~# '^\%(nowrite\)\=$'
      let absolute = substitute(tr(getcwd(), s:slash, '/'), '/\=$', '/', '') . absolute
  endif
  return s:UriFromPath(absolute)
endfunction

function! s:UriFromPath(absolute) abort
  let absolute = a:absolute
  if has('win32') && absolute =~# '^\a://\@!'
    return 'file:///' . strpart(absolute, 0, 2) . s:UrlEncode(strpart(absolute, 2))
  elseif absolute =~# '^/'
    return 'file://' . s:UrlEncode(absolute)
  elseif absolute =~# '^\a[[:alnum:].+-]*:\|^$'
    return absolute
  else
    return ''
  endif
endfunction

function! copilot#doc#Get() abort
  let absolute = tr(@%, s:slash, '/')
  if absolute !~# '^\a\+:\|^/\|^$' && &buftype =~# '^\%(nowrite\)\=$'
    let absolute = substitute(tr(getcwd(), s:slash, '/'), '/\=$', '/', '') . absolute
  endif
  let doc = {
    \ 'bufnr': bufnr(''),
    \ 'uri': s:UriFromBufnr(bufnr('')),
    \ 'version': getbufvar('', 'changedtick'),
    \ 'insertSpaces': v:true,
    \ 'tabSize': shiftwidth(),
    \ 'eol': 1,
    \ 'indentSize': shiftwidth(),
    \ }
  let line = getline('.')
  let col_byte = col('.') - (mode() =~# '^[iR]' || empty(line))
  let col_utf16 = copilot#doc#UTF16Width(strpart(line, 0, col_byte))
  let doc.position = {'line': line('.') - 1, 'character': col_utf16}
  return doc
endfunction

function! copilot#doc#Params(...) abort
  let extra = a:0 ? a:1 : {}
  let params = extend({'doc': extend(copilot#doc#Get(), get(extra, 'doc', {}))}, extra, 'keep')
  let params.textDocument = {
    \ 'uri': params.doc.uri,
    \ 'version': params.doc.version,
    \ }
  let params.position = params.doc.position
  return params.doc
endfunction
