scriptencoding utf-8

let g:copilot_setup_tip = "Copilot: Not logged in. Use ':Copilot setup' to log in and enable. For help, type ':help copilot'."
let g:copilot_login_tip = "Copilot: Enabled. Use ':help copilot' for help and ':Copilot feedback' to give feedback."

function! s:Echo(msg) abort
  if has('nvim') && &cmdheight == 0
    call v:lua.vim.notify(a:msg, v:null, {'title': 'Copilot'})
  else
    echo a:msg
  endif
endfunction

function! copilot#lsp#GetFiletypeDefaults() abort
  let copilot_filetype_defaults = {
  \ 'gitcommit': 0,
  \ 'gitrebase': 0,
  \ 'hgcommit': 0,
  \ 'svn': 0,
  \ 'cvs': 0,
  \ '.': 0}
  return copilot_filetype_defaults
endfunction

function! copilot#lsp#AcceptCompletionPart(snippet) abort
  let accept_method = 'gongfeng-notify/accept-completion-line'
  call s:AcceptCompletion(accept_method,a:snippet)
endfunction

function! copilot#lsp#AcceptCompletionAll() abort
  let accept_method = 'gongfeng-notify/accept-completion'
  call s:AcceptCompletion(accept_method)
endfunction

function! s:AcceptCompletion(accept_method,...) abort
  if (!exists('b:_copilot.suggestions') || !exists('b:_copilot.params'))
    return
  endif
  let choice = get(b:_copilot.suggestions, b:_copilot.choice, {})
  if has_key(choice, 'insertText')
    let choice.text = choice.insertText
    let snippet = a:0 ? a:1 : choice.insertText
    let params = {
      \ 'completionId': choice.id,
      \ 'snippet': snippet,
      \ 'uri': b:_copilot.params.uri,
      \ 'position': choice.range.start,
      \ 'insertPosition': choice.range.start,
      \ }
    let agent = copilot#Agent()
    call copilot#agent#WholeNotify(agent,a:accept_method,params)
  endif
endfunction

function! copilot#lsp#Completion(params,...) abort
  if !exists("g:copilot_login") || g:copilot_login == 0
    call copilot#logger#Info("Method gongfeng/stream-completions fail:Not logged in")
    return
  endif
  let completion_method = 'gongfeng/stream-completions'
  return call('copilot#agent#WholeRequest', [completion_method, a:params] + a:000)
endfunction

function! copilot#lsp#ConfigUpdate(agent,enable) abort
  let g:copilot_completion_enabled = a:enable
  let config_method = 'gongfeng/update-config'
  call copilot#agent#WholeRequest(config_method,copilot#lsp#GetUpdateConfig(), function('s:ConfigUpdateSuccess'),function('s:ConfigUpdateError'),a:agent)
endfunction

function! s:ConfigUpdateSuccess(result, agent) abort
  "echom 'ConfigUpdateSuccess'
  "echom a:result
endfunction

function! s:ConfigUpdateError(result, agent) abort
  "echom 'ConfigUpdateError'
  "echom a:result
endfunction

function! copilot#lsp#Initialized(agent,result) abort
  call copilot#logger#Info("[Response] " . json_encode(a:result))
  call copilot#agent#WholeNotify(a:agent,'initialized',{})
  call copilot#util#Defer({-> copilot#lsp#CheckConfig(a:agent)}) 
endfunction

function! copilot#lsp#GetDeviceCode(opts,agent) abort
  let auth_method = 'gongfeng/oauth-device-code'
  let params = {
    \ 'force': v:true,
    \ }
  call copilot#agent#WholeRequest(auth_method, params, function('s:GetDeviceCodeSuccess'),function('s:GetDeviceCodeError'),a:opts,a:agent)
endfunction

function! s:GetDeviceCodeError(opts,result, agent) abort
  echo a:result
endfunction

function! s:BrowserCallback(into, code) abort
  let a:into.code = a:code
endfunction

function! s:GetDeviceCodeSuccess(result, opts,agent) abort
  let auth_method = 'gongfeng/oauth-device-token'
  let params = {
    \ 'deviceCode': a:result.deviceCode,
    \ 'userCode': a:result.userCode,
    \ 'expiresAt': a:result.expiresAt,
    \ 'intervalMs': a:result.intervalMs,
    \ }

  let browser = copilot#Browser()
  let uri = a:result.verificationUri
  if has('clipboard')
    try
      let @+ = a:result.userCode
    catch
    endtry
    try
      let @* = a:result.userCode
    catch
    endtry
  endif
  let codemsg = "First copy your one-time code: " . a:result.userCode . "\n"
  try
    if len(&mouse)
      let mouse = &mouse
      set mouse=
    endif
    if get(a:opts, 'bang')
      call s:Echo(codemsg . "In your browser, visit " . uri)
    elseif len(browser)
      call input(codemsg . "Press ENTER to open 工蜂 in your browser\n")
      let status = {}
      call copilot#job#Stream(browser + [uri], v:null, v:null, function('s:BrowserCallback', [status]))
      call copilot#agent#WholeRequest(auth_method, params, function('s:GetTokenSuccess'),function('s:GetTokenError'),a:agent)
      let time = reltime()
      while empty(status) && reltimefloat(reltime(time)) < 5
        sleep 10m
      endwhile
      if get(status, 'code', browser[0] !=# 'xdg-open') != 0
        call s:Echo("Failed to open browser.  Visit " . uri)
      else
        call s:Echo("Opened " . uri . "\n" . "Waiting (could take up to 10 seconds)\n")
      endif
    else
      call copilot#agent#WholeRequest(auth_method, params, function('s:GetTokenSuccess'),function('s:GetTokenError'),a:agent)
      call s:Echo(codemsg . "Could not find browser.  Visit " . uri)
    endif
  finally
    if exists('mouse')
      let &mouse = mouse
    endif
  endtry
endfunction

function! s:GetTokenError(result, agent) abort
  echo a:result
endfunction

function! s:GetTokenSuccess(result, agent,...) abort
  let auth_method = 'gongfeng/authentication'
  let params = {
    \ 'token': a:result.accessToken,
    \ 'user': a:result.username,
    \ }
  let g:copilot_token = a:result.accessToken
  let g:copilot_user = a:result.username
  let g:copilot_show_tab_times = 0
  let g:copilot_show_login_times = 0
  let g:copilot_completion_enabled = 1
  call copilot#agent#WholeRequest(auth_method, params, function('s:AuthSuccess'), function('s:AuthError'), a:agent, params)
endfunction

function! s:AuthError(result, agent, params) abort
  echo g:copilot_setup_tip
endfunction

function! s:AuthSuccess(result, agent, params) abort
  if !exists('g:copilot_show_login_times') || g:copilot_show_login_times < 2
    echo g:copilot_login_tip
    let g:copilot_show_login_times += 1
    call copilot#agent#WholeRequest("gongfeng/update-config", copilot#lsp#GetUpdateConfig())
  endif
  if exists('g:copilot_new_version_params')
    if !has('win32')
      echo "Copilot: New version「" . g:copilot_new_version_params.version .  "」found"  . ",You can update by running 「curl -sL https://mirrors.tencent.com/repository/generic/gongfeng-copilot/vim/install.sh | VERSION=" . g:copilot_new_version_params.version . " sh」"
    else
      echo "Copilot: New version「 " . g:copilot_new_version_params.version .  "」found" . ",You can download latest version from 「https://mirrors.tencent.com/repository/generic/gongfeng-copilot/vim/gongfeng-copilot-vim-" . g:copilot_new_version_params.version . ".tar.gz」"
    endif
  endif
  let g:copilot_login = 1
  call copilot#lsp#ConfigUpdate(a:agent, g:copilot_completion_enabled)
endfunction

function! copilot#lsp#CheckConfig(agent) abort
  let config_method = 'gongfeng/update-config'
  call copilot#agent#WholeRequest(config_method, copilot#lsp#GetUpdateConfig(), function('s:GetConfigSuccess'),function('s:GetConfigError'),a:agent)
endfunction

function! s:GetConfigSuccess(result,agent) abort
  "echom "GetConfigSuccess"
  call copilot#logger#Debug(json_encode(a:result))
  if has_key(a:result, 'enableCompletions')
    let g:copilot_completion_enabled = empty(a:result.enableCompletions) ? 0 : 1
  else
    let g:copilot_completion_enabled = 1
  endif
  if has_key(a:result, 'completionLanguages')
    let g:copilot_completion_languages = a:result.completionLanguages
  endif
  if has_key(a:result, 'completionForceSingleLine')
    let g:copilot_completion_single_line = a:result.completionForceSingleLine
  else
    let g:copilot_completion_single_line = v:false
  endif
  if has_key(a:result, 'showLoginTimes')
    let g:copilot_show_login_times = a:result.showLoginTimes
  else
    let g:copilot_show_login_times = 0
  endif
  if has_key(a:result, 'showTabTimes')
    let g:copilot_show_tab_times = a:result.showTabTimes
  else
    let g:copilot_show_tab_times = 0
  endif
  if (has_key(a:result, 'token') && has_key(a:result, 'user')) && !empty(a:result.token) && !empty(a:result.user)
    let g:copilot_token = a:result.token
    let g:copilot_user = a:result.user
    let auth_method = 'gongfeng/authentication'
    let params = {
      \ 'token': a:result.token,
      \ 'user': a:result.user,
      \ }
      call copilot#agent#WholeRequest(auth_method, params, function('s:AuthSuccess'),function('s:RefreshToken'),a:agent,params)
  else
    echo g:copilot_setup_tip
  endif
endfunction

function! s:GetConfigErrorFirst(result,agent) abort
  call copilot#agent#WholeNotify(a:agent,'initialized',{})
  let config_method = 'gongfeng/update-config'
  call copilot#util#Defer({-> copilot#agent#WholeRequest(config_method, copilot#lsp#GetUpdateConfig(), function('s:GetConfigSuccess'),function('s:GetConfigError'),a:agent)})
endfunction

function! s:GetConfigError(result,agent) abort
  "echo g:copilot_setup_tip
endfunction

function! s:CheckConfigHandle(channel, msg)
   "echom "CheckConfigHandle"
   "echom a:msg
endfunction

function! s:RefreshToken(result,agent,old_params) abort
  let refresh_auth_method = 'gongfeng/refresh-token'
  let params = {
    \ 'token': a:old_params.token,
    \ 'user': a:old_params.user,
    \ }
  call copilot#agent#WholeRequest(refresh_auth_method, params, function('s:GetTokenSuccess'),function('s:RefreshTokenError'),a:agent)
endfunction

function! s:RefreshTokenError(result, agent) abort
  echo g:copilot_setup_tip
endfunction

function! copilot#lsp#GetUpdateConfig() abort
  let filetypes = copy(copilot#lsp#GetFiletypeDefaults())
  if type(get(g:, 'copilot_filetypes')) == v:t_dict
      call extend(filetypes, g:copilot_filetypes)
  endif
  let editor_config = {
    \ 'disabledLanguages': map(sort(keys(filter(filetypes, { k, v -> empty(v) }))), { _, v -> {'languageId': v}}),
    \ }
  if exists('g:copilot_completion_single_line')
    let editor_config['completionForceSingleLine'] = g:copilot_completion_single_line
  endif
  if exists('g:copilot_completion_languages')
    let editor_config['completionLanguages'] = g:copilot_completion_languages
  endif
  if exists('g:copilot_completion_enabled')
    let editor_config['enableCompletions'] = empty(g:copilot_completion_enabled) ? v:false : v:true
  endif
  if exists('g:copilot_show_tab_times')
    let editor_config['showTabTimes'] = g:copilot_show_tab_times
  endif
  if exists('g:copilot_show_login_times')
    let editor_config['showLoginTimes'] = g:copilot_show_login_times
  endif
  if exists("g:copilot_login") && g:copilot_login == 0
    let editor_config['token'] = ""
    let editor_config['user'] = ""
  else
    if exists('g:copilot_token')
      let editor_config['token'] = g:copilot_token
    endif
    if exists('g:copilot_user')
      let editor_config['user'] = g:copilot_user
    endif
  endif
  if exists('g:copilot_log_file')
    let editor_config['logPath'] = g:copilot_log_file
  endif
  return editor_config
endfunction

function! copilot#lsp#EnablePermission(lsp_file_path) abort
  let chmodCmd = 'chmod +x ' . a:lsp_file_path
  let out = []
  let err = []
  let status = copilot#job#Stream(chmodCmd, function('add', [out]), function('add', [err]))
  if status != 0
    let msg = 'chmod error:' . status . " file:" .lsp_file_path
    echoerr msg
    call copilot#logger#Error(msg)
  endif
endfunction
