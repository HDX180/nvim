require('ufo').setup({
  provider_selector = function(bufnr, filetype, buftype)
    return {'treesitter', 'indent'}
  end
})

vim.o.foldcolumn = '1' -- 设置折叠列宽度
vim.o.foldlevel = 99 -- 设置默认的折叠级别
vim.o.foldlevelstart = 99 -- 设置初始折叠级别
vim.o.foldenable = true -- 启用折叠
-- vim.o.foldmethod = 'expr' -- 使用表达式折叠
-- vim.o.foldexpr = 'nvim_treesitter#foldexpr()' -- 使用 Treesitter 进行折叠
