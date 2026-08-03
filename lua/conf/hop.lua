-- https://github.com/yuki-yano/hop.nvim (fork of phaazon/hop.nvim, upstream deleted)
local status_ok, hop = pcall(require, "hop")
if not status_ok then
  vim.notify("hop not found!")
  return
end

-- place this in one of your configuration file(s)
vim.api.nvim_set_keymap('n', 'f', "<cmd>HopWord<cr>", {})
