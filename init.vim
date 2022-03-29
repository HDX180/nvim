" Author: @danielhu
" set clipboard=unnamedplus

let &t_ut=''
set autochdir
filetype on
filetype plugin on
set encoding=utf-8

" ===
" === Auto load for first time uses
" ===
if empty(glob($HOME.'/.config/nvim/autoload/plug.vim'))
	silent !curl -fLo $HOME/.config/nvim/autoload/plug.vim --create-dirs
				\ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
	autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" ===
" === Editor behavior
" ===
" 语法高亮
syntax on
" 显示行号
set number
set relativenumber
" 显示当前行
set cursorline
" 超过屏幕内容自动换行
" set wrap
" 显示指令
set showcmd
" display all matching files when we tab complete 
set wildmenu
" 高亮显示搜索
set hlsearch
" 动态高亮搜索
set incsearch
" 不区分大小写搜索
set ignorecase
" 使用空格替换tab
set expandtab
" 设置所有的Tab和缩进为2
set tabstop=2
" 设定<<和>>移动时的宽度为2
set shiftwidth=2
" 滚动时保持顶部或底部留5行
set scrolloff=5
set exrc
set secure
" 自动换行
set autoindent
set indentexpr=
" split 右边,下边
set splitright
set splitbelow
" 设置tab栏
set showtabline=2
" 设置leader建
let mapleader=';'
" lightline已经显示mode
set noshowmode

" ===
" === vim-plug
" ===
call plug#begin('~/.config/nvim/plugged')
  " Plug 'EdenEast/nightfox.nvim'
  Plug 'arcticicestudio/nord-vim'
  " lsp 代码补全
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
  " syntax highlight
  Plug 'nvim-treesitter/nvim-treesitter'
  " Status line
  Plug 'itchyny/lightline.vim'
  " GIt
  Plug 'tpope/vim-fugitive'
  " find
  Plug 'Yggdroot/LeaderF'
  " 注释
  Plug 'tomtom/tcomment_vim'
  " devicons
  Plug 'kyazdani42/nvim-web-devicons'
  " buffer line
  " Plug 'akinsho/bufferline.nvim'
  " terminal
  Plug 'skywind3000/vim-terminal-help'
  " start
  Plug 'mhinz/vim-startify'
  " smooth
  Plug 'psliwka/vim-smoothie'
  " 多光标
  Plug 'mg979/vim-visual-multi'
  " tree
  Plug 'kyazdani42/nvim-tree.lua'
  " 快速move
  Plug 'phaazon/hop.nvim'
  " auto pair
  Plug 'jiangmiao/auto-pairs'
call plug#end()

let $NVIM_TUI_ENABLE_TRUE_COLOR=1
set termguicolors " enable true colors support
" nord
augroup nord-theme-overrides
  autocmd!
  autocmd ColorScheme nord highlight LineNr guifg=#9da2ac
  autocmd ColorScheme nord highlight CursorLineNr guifg=#83b9c8
  autocmd ColorScheme nord highlight CocHighlightText gui=underline guifg=#88c0d0 guibg=#3e4655
  autocmd ColorScheme nord highlight CocErrorSign guifg=#fa8072
  autocmd ColorScheme nord highlight Lf_hl_match gui=bold guifg=#EBCB8B
  autocmd ColorScheme nord highlight Lf_hl_match0 gui=bold guifg=#EBCB8B
  autocmd ColorScheme nord highlight HopNextKey gui=bold guifg=#88C0D0
  autocmd ColorScheme nord highlight HopNextKey1 gui=bold guifg=#88C0D0
  autocmd ColorScheme nord highlight HopNextKey2 gui=bold guifg=#5E81AC
  autocmd ColorScheme nord highlight CocErrorHighlight guifg=#fa8072
augroup END
" colorscheme
colorscheme nord

" ===
" leaderf
" don't show the help in normal mode
let g:Lf_HideHelp = 1
let g:Lf_UseCache = 0
let g:Lf_UseVersionControlTool = 0
let g:Lf_IgnoreCurrentBufferName = 1
" popup mode
" let g:Lf_WindowPosition = 'popup'
let g:Lf_PreviewCode = 1
let g:Lf_PreviewInPopup = 1
let g:Lf_PreviewResult = {
    \ 'Function': 1,
    \ 'Gtags': 1,
    \ 'Rg': 1
    \ }
" 查找rootpath规则
let g:Lf_WorkingDirectoryMode = 'Ac'
" 查找rootpath文件列表
let g:Lf_RootMarkers = ['.git', '.project', '.root']
let g:Lf_ShortcutF = '<c-p>'
let g:Lf_WildIgnore = {'file':['*.o', '*.so', '*.a']}
let g:Lf_ShowDevIcons = 1
let g:Lf_GtagsAutoGenerate = 1
let g:Lf_GtagsAutoUpdate = 1
let g:Lf_WindowHeight = 0.30
let g:Lf_StlSeparator = { 'left': "\ue0b0", 'right': "\ue0b2" }
nnoremap <leader>gr :<C-U><C-R>=printf("Leaderf! gtags -r %s", expand("<cword>"))<CR><CR>
nnoremap <leader>gd :<C-U><C-R>=printf("Leaderf! gtags -d %s --auto-jump", expand("<cword>"))<CR><CR>
nnoremap <leader>gf :LeaderfFunction<cr>
nnoremap <leader>gu :Leaderf gtags --update<cr>

" noremap <leader>f :<C-U><C-R>=printf("Leaderf rg --append ")<CR>
noremap <leader>f :<C-U><C-R>=printf("Leaderf! rg -e %s ", expand("<cword>"))<CR><CR>

" === coc
let g:coc_global_extensions = [
  \'coc-json',
  \'coc-highlight',
  \'coc-vimlsp',
  \]
set hidden
set updatetime=300
set nobackup
set nowritebackup
set shortmess+=c
set signcolumn=number
" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')
" 函数签名
autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
" Symbol renaming.
" nmap <Leader>rn <Plug>(coc-rename)

function! s:show_documentation()
	call CocActionAsync('highlight')
	if (index(['vim','help'], &filetype) >= 0)
		execute 'h '.expand('<cword>')
	else
		call CocAction('doHover')
	endif
endfunction
nnoremap <silent> K :call <SID>show_documentation()<CR>
" selection：选择函数（内部、全部）
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)

" fugitive
" autocmd BufReadPost fugitive

" tab 切换提示
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
	  let col = col('.') - 1
		  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" enter确认所选instead of 换行
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                                \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
" 跳转诊断错误
nmap <silent> g[ <Plug>(coc-diagnostic-prev)
nmap <silent> g] <Plug>(coc-diagnostic-next)
" save without format
" :noa w

" hop
lua << EOF
require'hop'.setup()
EOF
nmap f :HopWord<CR>

" nvim-tree 
nnoremap tt :NvimTreeToggle<CR>
let g:nvim_tree_git_hl = 1 
let g:nvim_tree_highlight_opened_files = 3
let g:nvim_tree_group_empty = 1
" let g:nvim_tree_respect_buf_cwd = 1
let g:nvim_tree_create_in_closed_folder = 1
lua << EOF
require'nvim-tree'.setup {
  auto_close = true,
  -- update_cwd = true,
  update_focused_file = {
    enable      = true,
    update_cwd  = true,
    ignore_list = {}
  },
}
EOF

" === nightfox
" lua << EOF
" local nightfox = require('nightfox')
" nightfox.setup({
"   styles = {
"     comments = "italic", -- change style of comments to be italic
"     -- keywords = "bold", -- change style of keywords to be bold
"     -- functions = "italic,bold" -- styles can be a comma separated list
"   },
"   inverse = {
"     match_paren = true, -- inverse the highlighting of match_parens
"   },
"   -- colors = {
"   --   red = "#FF000", -- Override the red color for MAX POWER
"   --   bg_alt = "#000000",
"   -- }
"   hlgroups = {
"     -- TSPunctDelimiter = { fg = "${red}" }, -- Override a highlight group with the color red
"     -- LspCodeLens = { bg = "#000000", style = "italic" },
"     CocHighlightText = { style = "underline", fg = "#88c0d0", bg="#3e4655" },
"     CocErrorSign = { fg = "#b95f68" },
"     LineNr = { fg = "#9da2ac" },
"     CursorLineNr = { fg = "#83b9c8" },
"     -- Comment = { fg = "#9da2ac" }
"   }
" })
" -- Load the configuration set above and apply the colorscheme
" nightfox.load()
" EOF

" === lightline
function! CurrentFunction()
    return get(b:, 'coc_current_function', '')
endfunction
function CurSession()
  return fnamemodify(v:this_session,':t')
endfunction
function! LightlineFilename()
  let filename = expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  let modified = &modified ? ' +' : ''
  return filename . modified
endfunction
let g:lightline = {
      \ 'colorscheme': 'nord',
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch' ],
      \             [ 'cur_session' ],
      \             [ 'readonly', 'filename', 'function'] ]
      \ },
      \ 'tabline': {
      \   'right': [ [] ]
      \ },
      \ 'component': {
      \   'lineinfo': '%3l:%-2v%<',
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead',
      \   'cur_session': 'CurSession',
      \   'filename': 'LightlineFilename',
      \   'function': 'CurrentFunction',
      \ },
			\ 'enable': { 'tabline': 0 },
\ }
let g:lightline.separator    =  {'left': "\ue0b0", 'right': "\ue0b2"}
" let g:lightline.subseparator =  {'left': "\ue0b1", 'right': "\ue0b3"}
let g:lightline.subseparator =  {'left': " ", 'right': " "}
au BufEnter,BufWinEnter,WinEnter * call s:disable_statusline()
fun! s:disable_statusline()
if &filetype == 'NvimTree' || &filetype == 'startify'
  set laststatus=0
else
  set laststatus=2
endif
endfunction

" " === bufferline
" lua << EOF
" require("bufferline").setup {
"     options = {
"         show_buffer_close_icons = false,
"         -- 左侧让出 nvim-tree 的位置
"         offsets = {{
"             filetype = "NvimTree",
"             text = "File Explorer",
"             highlight = "Directory",
"             text_align = "left"
"         }},
"         sort_by = function(buffer_a, buffer_b)
"           return buffer_a.modified > buffer_b.modified
"         end
"     }
" }
" EOF
" nnoremap <silent> gb :BufferLinePick<CR>
" nnoremap <silent> gB :BufferLinePickClose<CR>

" ===
" === nvim-treesitter
" ===
lua <<EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = {'c', 'cpp', 'json', 'python', 'bash'},
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
}
EOF

" startify
function! OnSessionBeforeSave()
  execute "NvimTreeClose"
  call TerminalClose()
  if winnr("$") > 1
    execute "q"
  endif
endfunction
nmap gs :split<CR>:res -10<CR>:Startify<CR>
" nnoremap <leader>sp :SSave<CR>
" nnoremap <leader>cp :SDelete<CR>
let g:startify_custom_header = ''
let g:startify_enable_special = 0
let g:startify_session_persistence = 1
let g:startify_session_before_save = [ 'call OnSessionBeforeSave()' ]
let g:startify_lists = [
          \ { 'type': 'sessions', 'header': ['Sessions'] },
          \ ]
let g:startify_custom_indices = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'l', 'm', 'n']

" Indentation
nnoremap < <<
nnoremap > >>
noremap H ^
noremap L $
nnoremap U <C-r>
nnoremap D d$
nnoremap Y y$

inoremap <C-a> <Right>
inoremap kj <ESC>

map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l

map <up> :res +5<CR>
map <down> :res -5<CR>
map <left> :vertical resize-5<CR>
map <right> :vertical resize+5<CR>

" Search
noremap <LEADER>/ :nohlsearch<CR>

" terminal
tnoremap <Esc> <C-\><C-n>
let g:terminal_key = '<LEADER>t'
let g:terminal_kill = 'term'
let g:terminal_list = 0
let g:terminal_height = 20

" 切换头文件和源文件
function! HeaderToggle()
    let filename = expand("%:t")
    if filename =~ ".cpp" || filename =~ ".cc"
        execute "e %:r.h"
    else
        let switch_cc_file = join([expand("%<"), ".cc"], "")
        let switch_cpp_file = join([expand("%<"), ".cpp"], "")
        if filereadable(switch_cc_file)
          execute "e %:r.cc"
        elseif filereadable(switch_cpp_file)
          execute "e %:r.cpp"
        else 
          echo "nothing"
        endif
    endif
endfunction
nmap <C-s> :call HeaderToggle()<CR>

" 替换复制单词
nmap cp ciw<C-r>0<ESC>

nmap <leader>i :e $MYVIMRC<CR>
autocmd BufWritePost $MYVIMRC source $MYVIMRC

