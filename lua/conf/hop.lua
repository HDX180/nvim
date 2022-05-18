-- https://github.com/phaazon/hop.nvim
local status_ok, hop = pcall(require, "hop")
if not status_ok then
  vim.notify("hop not found!")
  return
end
hop.setup()

-- place this in one of your configuration file(s)
vim.api.nvim_set_keymap('n', 'f', "<cmd>HopWord<cr>", {})
