-- Indent-blankline 配置
local highlight = {
    "RainbowPurple",
}
local hooks = require "ibl.hooks"
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, "RainbowPurple", { fg = "#645784" })
end)

require("ibl").setup {
  -- indent = {
  --   char = "┆", -- 你可以选择其他符号，如 "┆", "│", "⎸", "¦"
  -- },
  scope = {
    enabled = true, -- 启用上下文显示
    show_start = false, -- 从当前上下文的开始位置展示
    show_end = false, -- 不显示上下文结束位置
    highlight = highlight,
  },
  exclude = {
    buftypes = {"terminal"},
    filetypes = {"help", "dashboard", "packer", "NvimTree", "toggleterm"},
  },
}
