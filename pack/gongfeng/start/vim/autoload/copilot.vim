scriptencoding utf-8

let s:has_nvim_ghost_text = has('nvim-0.6') && exists('*nvim_buf_get_mark')
let s:vim_minimum_version = '9.0.0185'
let s:has_vim_ghost_text = has('patch-' . s:vim_minimum_version) && has('textprop')
let s:has_ghost_text = s:has_nvim_ghost_text || s:has_vim_ghost_text

let s:hlgroup = 'CopilotSuggestion'
let s:annot_hlgroup = 'CopilotAnnotation'
let s:root = expand('<sfile>:h:h')
let s:os = tolower(system('uname'))
let s:arch = tolower(system('uname -m'))

if s:has_vim_ghost_text && empty(prop_type_get(s:hlgroup))
  call prop_type_add(s:hlgroup, {'highlight': s:hlgroup})
endif
if s:has_vim_ghost_text && empty(prop_type_get(s:annot_hlgroup))
  call prop_type_add(s:annot_hlgroup, {'highlight': s:annot_hlgroup})
endif

function! s:BufferDisabled() abort
  if &buftype =~# '^\%(help\|prompt\|quickfix\|terminal\)$'
    return 5
  endif

  if exists('b:copilot_disabled')
    return empty(b:copilot_disabled) ? 0 : 3
  endif

  if exists('b:copilot_completion_enabled')
    return empty(b:copilot_completion_enabled) ? 4 : 0
  endif

  let short = empty(&l:filetype) ? '.' : split(&l:filetype, '\.', 1)[0]
  let config = {}
  if type(get(g:, 'copilot_filetypes')) == v:t_dict
    let config = g:copilot_filetypes
  endif

  if has_key(config, &l:filetype)
    return empty(config[&l:filetype])
  elseif has_key(config, short)
    return empty(config[short])
  elseif has_key(config, '*')
    return empty(config['*'])
  else
    return get(copilot#lsp#GetFiletypeDefaults(), short, 1) == 0 ? 2 : 0
  endif
endfunction

function! copilot#Init(...) abort
  let delay = 1500
  call timer_stop(get(g:, '_copilot_start_timer', -1))
  let g:_copilot_start_timer = timer_start(delay, function('s:InitDelay'))
endfunction

function! s:InitDelay(timer) abort
  unlet! g:_copilot_start_timer
  call copilot#util#Defer({ -> exists('s:agent') || s:Start() })
endfunction

function! s:Running() abort
  return exists('s:agent.job') || exists('s:agent.client_id')
endfunction

function! s:Start() abort
  if s:Running()
      return
  endif
  call s:CopilotNew()
endfunction

function! s:CopilotNew() abort
  let s:agent = copilot#agent#New()
endfunction

function! copilot#Agent() abort
  call s:Start()
  return s:agent
endfunction

function! s:Attach(bufnr, ...) abort
  try
    return copilot#Agent().Attach(a:bufnr)
  catch
  endtry
endfunction

function! copilot#Clear() abort
  if exists('g:_copilot_timer')
    call timer_stop(remove(g:, '_copilot_timer'))
  endif
  if exists('b:_copilot')
    call copilot#agent#Cancel(get(b:_copilot, 'first', {}))
    call copilot#agent#Cancel(get(b:_copilot, 'cycling', {}))
  endif
  call s:UpdatePreview()
  unlet! b:_copilot
  return ''
endfunction

function! copilot#OnCompleteChanged() abort
  if s:HideDuringCompletion()
    return copilot#Clear()
  else
    return copilot#Schedule()
  endif
endfunction

function! copilot#OnInsertLeave() abort
  return copilot#Clear()
endfunction

function! copilot#OnInsertEnter() abort
  return copilot#Schedule()
endfunction

function! copilot#OnCursorMovedI() abort
  return copilot#Schedule()
endfunction

function! copilot#NvimNs() abort
  return nvim_create_namespace('copilot')
endfunction

function! s:ClearPreview() abort
  if s:has_nvim_ghost_text
    call nvim_buf_del_extmark(0, copilot#NvimNs(), 1)
  elseif s:has_vim_ghost_text
    call prop_remove({'type': s:hlgroup, 'all': v:true})
    call prop_remove({'type': s:annot_hlgroup, 'all': v:true})
  endif
endfunction
  
function! s:UpdatePreview() abort
  try
    let [text, outdent, delete, uuid] = s:SuggestionTextWithAdjustments()
    let text = split(text, "\n", 1)
    if empty(text[-1])
      call remove(text, -1)
    endif
    if empty(text) || !s:has_ghost_text
      return s:ClearPreview()
    endif
    if exists('b:_copilot.cycling_callbacks')
      let annot = '(1/…)'
    elseif exists('b:_copilot.cycling')
      let annot = '(' . (b:_copilot.choice + 1) . '/' . len(b:_copilot.suggestions) . ')'
    else
      let annot = ''
    endif
      call s:ClearPreview()
      if s:has_nvim_ghost_text
        let data = {'id': 1}
        let data.virt_text_pos = 'overlay'
        let append = strpart(getline('.'), col('.') - 1 + delete)
        let data.virt_text = [[text[0] . append . repeat(' ', delete - len(text[0])), s:hlgroup]]
        if len(text) > 1
          let data.virt_lines = map(text[1:-1], { _, l -> [[l, s:hlgroup]] })
          if !empty(annot)
            let data.virt_lines[-1] += [[' '], [annot, s:annot_hlgroup]]
          endif
        elseif len(annot)
          let data.virt_text += [[' '], [annot, s:annot_hlgroup]]
        endif
        let data.hl_mode = 'combine'
        call nvim_buf_set_extmark(0, copilot#NvimNs(), line('.')-1, col('.')-1, data)
      else
        call prop_add(line('.'), col('.'), {'type': s:hlgroup, 'text': text[0]})
        if !exists('g:copilot_show_tab_times') || g:copilot_show_tab_times < 3
          call prop_add(line('.'), col('$'), {'type': s:hlgroup, 'text': "          按 Tab 全部采纳"})
        endif
        for line in text[1:]
          call prop_add(line('.'), 0, {'type': s:hlgroup, 'text_align': 'below', 'text': line})
        endfor
        if !empty(annot)
          call prop_add(line('.'), col('$'), {'type': s:annot_hlgroup, 'text': ' ' . annot})
        endif
      endif
  catch
  endtry
endfunction

function! s:HideDuringCompletion() abort
  return get(g:, 'copilot_hide_during_completion', 1)
endfunction

function! s:SuggestionTextWithAdjustments() abort
  try
    if mode() !~# '^[iR]' || (s:HideDuringCompletion() && pumvisible()) || !exists('b:_copilot.suggestions')
      return ['', 0, 0, '']
    endif
    let choice = get(b:_copilot.suggestions, b:_copilot.choice, {})
    if has_key(choice, 'insertText')
      let choice.text = substitute(choice.insertText, '\r', '', '')
    endif
    if !has_key(choice, 'range') || choice.range.start.line != line('.') - 1 || type(choice.text) !=# v:t_string
      return ['', 0, 0, '']
    endif
    let line = getline('.')
    let offset = col('.') - 1
    let choice_text = strpart(line, 0, copilot#doc#UTF16ToByteIdx(line, choice.range.start.character)) . substitute(choice.text, "\n*$", '', '')
    let typed = strpart(line, 0, offset)
    let end_offset = copilot#doc#UTF16ToByteIdx(line, choice.range.end.character)
    if end_offset < 0
      let end_offset = len(line)
    endif
    let delete = strpart(line, offset, end_offset - offset)
    let uuid = get(choice, 'uuid', '')
    if typed =~# '^\s*$'
      let leading = matchstr(choice_text, '^\s\+')
      let unindented = strpart(choice_text, len(leading))
    if strpart(typed, 0, len(leading)) == leading && unindented !=# delete
      return [unindented, len(typed) - len(leading), strchars(delete), uuid]
    endif
    elseif typed ==# strpart(choice_text, 0, offset)
      return [strpart(choice_text, offset), 0, strchars(delete), uuid]
    endif
  catch
  endtry
  return ['', 0, 0, '']
endfunction

function! copilot#Next() abort
  " 只有一个结果，无需任何操作
endfunction

function! copilot#Previous() abort
  " 只有一个结果，无需任何操作
endfunction

function! s:HandleTriggerResult(result) abort
  if !exists('b:_copilot')
    return
  endif
  let b:_copilot.suggestions = get(a:result, 'completions', [])
  let b:_copilot.choice = 0
  call s:UpdatePreview()
endfunction

function! copilot#Suggest() abort
  if !s:Running()
    return ''
  endif
  try
    call copilot#Complete(function('s:HandleTriggerResult'), function('s:HandleTriggerResult'))
  catch
    return ''
  endtry
  return ''
endfunction

function! s:Callback(request, type, callback, timer) abort
  call remove(a:request.waiting, a:timer)
  if has_key(a:request, a:type)
    call a:callback(a:request[a:type])
  endif
endfunction

function! copilot#Complete(...) abort
  if exists('g:_copilot_timer')
    call timer_stop(remove(g:, '_copilot_timer'))
  endif
  let params = copilot#doc#Params()
  " 额外参数
  let params.extOptions = {
    \ 'forceCompletionSingleline': exists('g:copilot_completion_single_line')?g:copilot_completion_single_line: v:false,
    \ }
  if exists('g:copilot_completion_languages')
    let params.extOptions.disabledLanguages = g:copilot_completion_languages
  endif
  if !exists('b:_copilot.params') || b:_copilot.params !=# params
    if exists('b:_copilot.first')
      call copilot#agent#Cancel(b:_copilot.first)
    endif
    if exists('b:_copilot.cycling')
      call copilot#agent#Cancel(b:_copilot.cycling)
    endif
    let b:_copilot = {'params': params, 'first':
      \ copilot#lsp#Completion(params)}
    let g:_copilot_last = b:_copilot
  endif
  let completion = b:_copilot.first
  if !a:0
    return completion.Await()
  else
    call copilot#agent#Result(completion, a:1)
  endif
endfunction

function! s:Trigger(bufnr, timer) abort
  if exists('g:copilot_completion_enabled') &&  empty(g:copilot_completion_enabled)
    return
  endif
  let timer = get(g:, '_copilot_timer', -1)
  if a:bufnr !=# bufnr('') || a:timer isnot# timer || mode() !=# 'i'
    return
  endif
  unlet! g:_copilot_timer
  return copilot#Suggest()
endfunction

function! copilot#Schedule(...) abort
  call s:UpdatePreview()
  let delay = a:0 ? a:1 : get(g:, 'copilot_idle_delay', 30)
  call timer_stop(get(g:, '_copilot_timer', -1))
  let g:_copilot_timer = timer_start(delay, function('s:Trigger', [bufnr('')]))
endfunction

function! copilot#OnFileType() abort
  if empty(s:BufferDisabled()) && &l:modifiable && &l:buflisted
    call copilot#util#Defer(function('s:Attach'), bufnr(''))
  endif
endfunction

function! copilot#GetDisplayedSuggestion() abort
  let [text, outdent, delete, uuid] = s:SuggestionTextWithAdjustments()

  return {
    \ 'uuid': uuid,
    \ 'text': text,
    \ 'outdentSize': outdent,
    \ 'deleteSize': delete}
endfunction

function! copilot#Accept(...) abort
  let s = copilot#GetDisplayedSuggestion()
  if !empty(s.text)
    let text = ''
    if a:0 > 1
      let text = substitute(matchstr(s.text, "\n*" . '\%(' . a:2 .'\)'), "\n*$", '', '')
    endif
    if empty(text)
      let text = s.text
    endif
    if exists('g:copilot_show_tab_times') && g:copilot_show_tab_times < 3
      let g:copilot_show_tab_times += 1
      call copilot#agent#WholeRequest("gongfeng/update-config", copilot#lsp#GetUpdateConfig())
    endif
    if !a:0
      call copilot#lsp#AcceptCompletionAll()
    else
      call copilot#lsp#AcceptCompletionPart(text)
    endif
    unlet! b:_copilot
    let acceptance = {'uuid': s.uuid}
    if text !=# s.text
      let acceptance.acceptedLength = copilot#doc#UTF16Width(text)
    endif
    call s:ClearPreview()
    let s:suggestion_text = text
    return repeat("\<Left>\<Del>", s.outdentSize) . repeat("\<Del>", s.deleteSize) .
            \ "\<C-R>\<C-O>=copilot#TextQueuedForInsertion()\<CR>" . (a:0 > 1 ? '' : "\<End>")
  endif
  let default = get(g:, 'copilot_tab_fallback', pumvisible() ? "\<C-N>" : "\t")
  if !a:0
    return default
  elseif type(a:1) == v:t_string
    return a:1
  elseif type(a:1) == v:t_func
    try
      return call(a:1, [])
    catch
      return default
    endtry
  else
    return default
  endif
endfunction

function! copilot#TextQueuedForInsertion() abort
  try
    return remove(s:, 'suggestion_text')
  catch
    return ''
  endtry
endfunction

function! copilot#AcceptWord(...) abort
  return copilot#Accept(a:0 ? a:1 : '', '\%(\k\@!.\)*\k*')
endfunction
  
function! copilot#AcceptLine(...) abort
  return copilot#Accept(a:0 ? a:1 : "\r", "[^\n]\\+")
endfunction

function! s:completionEnable () abort
  let enable = 1
  if exists('g:copilot_completion_enabled')
    let enable = g:copilot_completion_enabled
  endif
  return enable ==# 0 ? v:false : v:true
endfunction


function! copilot#Browser() abort
  if type(get(g:, 'copilot_browser')) == v:t_list
    let cmd = copy(g:copilot_browser)
  elseif type(get(g:, 'open_command')) == v:t_list
    let cmd = copy(g:open_command)
  elseif has('win32')
    let cmd = ['rundll32', 'url.dll,FileProtocolHandler']
  elseif has('mac')
    let cmd = ['open']
  elseif executable('wslview')
    return ['wslview']
  elseif executable('xdg-open')
    return ['xdg-open']
  else
    return []
  endif
  if executable(get(cmd, 0, ''))
    return cmd
  else
    return []
  endif
endfunction

let s:commands = {}

function! s:commands.signout(opts) abort
  echo g:copilot_setup_tip
  let g:copilot_login = 0
  let g:copilot_show_tab_times = 0
  let g:copilot_show_login_times = 0
  let g:copilot_completion_enabled = 1
  call copilot#agent#WholeRequest("gongfeng/logout", {})
  call copilot#agent#WholeRequest("gongfeng/update-config", copilot#lsp#GetUpdateConfig())
endfunction

function! s:commands.setup(opts) abort
  if !has('nvim-0.6') && v:version < 900
      echo "Vim version too old,requires 9.0.0185 or higher"
      return
  endif
  let agent = copilot#Agent()
  call copilot#lsp#GetDeviceCode(a:opts,agent)
endfunction

let s:commands.auth = s:commands.setup
let s:commands.signin = s:commands.setup

function! s:commands.log(opts) abort
  if exists('g:copilot_log_file')
    echo g:copilot_log_file
  else
    echo 'Copilot log file not set'
  endif
  return a:opts.mods . ' split +$ copilot:///log'
endfunction

function! s:commands.version(opts) abort
  echo copilot#version#String()
endfunction

function! s:commands.force_slc(opts) abort
  if len(a:opts.arg)
    if a:opts.arg =~? 'true\|false'
      if a:opts.arg =~? 'true'
        let g:copilot_completion_single_line = v:true
      else
        let g:copilot_completion_single_line = v:false
      endif
      echo 'Copilot: ' . (g:copilot_completion_single_line? 'true' : 'false')
      call copilot#agent#WholeRequest("gongfeng/update-config", copilot#lsp#GetUpdateConfig())
    else
      echoerr "Copilot: Argument must be 'true' or 'false'"
    endif
  else
    if exists('g:copilot_completion_single_line')
      echo 'Copilot: ' . g:copilot_completion_single_line
    else
      echo 'Copilot: false'
    endif
  endif
endfunction

function! s:commands.languages(opts) abort
  if len(a:opts.arg)
    let l:json_obj = {}
    try
      let l:json_obj = json_decode(a:opts.arg)
      let g:copilot_completion_languages = l:json_obj
      echo 'Copilot: ' . json_encode(g:copilot_completion_languages)
      call copilot#agent#WholeRequest("gongfeng/update-config", copilot#lsp#GetUpdateConfig())
    catch /E730/
      echoerr "Copilot: Argument is not a valid JSON string"
      return
    endtry
  else
    if exists('g:copilot_completion_languages')
      echo 'Copilot: ' . json_encode(g:copilot_completion_languages)
    else
      echo "Copilot: Empty languages"
    endif
  endif
endfunction

function! s:commands.update(opts) abort
  if exists('g:copilot_new_version_params')
    if !has('win32')
      echo "Copilot: New version「" . g:copilot_new_version_params.version .  "」found"  . ",You can update by running 「curl -sL https://mirrors.tencent.com/repository/generic/gongfeng-copilot/vim/install.sh | VERSION=" . g:copilot_new_version_params.version . " sh」"
    else
      echo "Copilot: New version「 " . g:copilot_new_version_params.version .  "」found" . ",You can download latest version from 「https://mirrors.tencent.com/repository/generic/gongfeng-copilot/vim/gongfeng-copilot-vim-" . g:copilot_new_version_params.version . ".tar.gz」"
    endif
  else
    echo "Copilot :Is already up to date"
  endif
endfunction

function! s:commands.disable(opts) abort
  let agent = copilot#Agent()
  call copilot#lsp#ConfigUpdate(agent,0)
  call s:debugStatus()
endfunction

let s:feedback_url = 'https://git.woa.com/tencent-git/code-generation/issues'
function! s:commands.feedback(opts) abort
  echo 'Copilot: Please provide feedback at ' . s:feedback_url
  let browser = copilot#Browser()
  if len(browser)
    call copilot#job#Stream(browser + [s:feedback_url], v:null, v:null, v:null)
  endif
endfunction

function! s:commands.enable(opts) abort
  let agent = copilot#Agent()
  call copilot#lsp#ConfigUpdate(agent,1)
  call s:debugStatus()
endfunction

function! s:commands.status(opts) abort
  call s:debugStatus()
endfunction

function! s:debugStatus() abort
  if !exists("g:copilot_login") || g:copilot_login == 0
    echo "Copilot: Not logged in"
    return
  endif
  if s:completionEnable()
    echo 'Copilot: Auto-completion is enabled.'
  else
    echo 'Copilot: Auto-completion is disabled, you can manually trigger the completion using the shortcut: ' . copilot#shortcut#trigger()
  endif
endfunction

function! s:commands.help(opts) abort
  return a:opts.mods . ' help ' . (len(a:opts.arg) ? ':Copilot_' . a:opts.arg : 'copilot')
endfunction

function! copilot#CommandComplete(arg, lead, pos) abort
  let args = matchstr(strpart(a:lead, 0, a:pos), 'C\%[opilot][! ] *\zs.*')
  if args !~# ' '
    return sort(filter(map(keys(s:commands), { k, v -> tr(v, '_', '-') }),
          \ { k, v -> strpart(v, 0, len(a:arg)) ==# a:arg }))
  else
    return []
  endif
endfunction

function! copilot#Command(line1, line2, range, bang, mods, arg) abort
  let cmd = matchstr(a:arg, '^\%(\\.\|\S\)\+')
  let arg = matchstr(a:arg, '\s\zs\S.*')
  if !empty(cmd) && !has_key(s:commands, tr(cmd, '-', '_'))
    return 'echoerr ' . string('Copilot: unknown command ' . string(cmd))
  endif
  try
    let opts = {}
    call extend(opts, {'line1': a:line1, 'line2': a:line2, 'range': a:range, 'bang': a:bang, 'mods': a:mods, 'arg': arg})
    let retval = s:commands[tr(cmd, '-', '_')](opts)
    if type(retval) == v:t_string
      return retval
    else
      return ''
    endif
  catch /^Copilot:/
    return 'echoerr ' . string(v:exception)
  endtry
endfunction
