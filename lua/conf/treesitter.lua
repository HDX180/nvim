local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then
  vim.notify("treesitter not found!")
  return
end

-- require 'nvim-treesitter.install'.compilers = { "clang++" }

configs.setup {
  ensure_installed = { "cpp", "c", "vimdoc", "python", "go", "markdown", "json", "yaml", "bash", "lua" }, 
  sync_install = false,
  ignore_install = { "" },
  highlight = {
    enable = true,
    disable = function(lang, bufnr)
      local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
      -- 如果文件类型为 nvim-tree 或缓冲区名称匹配 nvim-tree 模式，则禁用高亮
      if filetype == "NvimTree" or filetype == "toggleterm" then
        return true
      end
      -- 可以根据需要添加其他禁用条件
      return false
    end,
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
