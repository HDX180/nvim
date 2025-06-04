vim.cmd [[
  augroup _format
    autocmd!
    " autocmd BufWritePre * :Format 
  augroup END
]]

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    if vim.bo.filetype == "codecompanion" then
      vim.opt_local.number = false
    end
  end,
})
