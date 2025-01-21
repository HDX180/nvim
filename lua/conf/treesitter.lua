local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  vim.notify("treesitter not found!")
  return
end

require 'nvim-treesitter.install'.compilers = { "clang++" }

configs.setup {
  ensure_installed = { "cpp", "c", "python", "go", "markdown", "json", "yaml", "bash", "lua" }, 
  sync_install = false,
  ignore_install = { "" },
  highlight = {
    enable = true,
    disable = { "vimdoc" }, -- list of language that will be disabled
    additional_vim_regex_highlighting = false,
  },
  -- 启用增量选择
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<CR>',
      node_incremental = '<CR>',
      node_decremental = '<BS>', -- del键
      scope_incremental = '<TAB>',
    }
  },
  -- 启用基于Treesitter的缩进(==)
  indent = {
    enable = true
  },
  -- 折叠
  fold = {
    enable = true
  }
}
-- 设置折叠方法为 treesitter
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'
vim.o.foldmethod = 'manual'
