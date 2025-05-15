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

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    if vim.bo.filetype == "codecompanion" then
      vim.opt_local.number = false
    end
  end,
})
