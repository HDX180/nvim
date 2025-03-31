vim.cmd [[
  augroup _format
    autocmd!
    " autocmd BufWritePre * :Format 
  augroup END

  " 为了使选中的buf区别于未选中的buf颜色
  " augroup transparent_background
  "   au!
  "   au VimEnter * hi Normal ctermbg=NONE guibg=NONE
  " augroup END
]]
