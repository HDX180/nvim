local status_ok, codediff = pcall(require, "codediff")
if not status_ok then
  return
end

codediff.setup {}

-- codediff 加载时可能会全局开启 signcolumn / 修改 statuscolumn,
-- 导致普通 buffer 的行号被状态符号 (W/E 等) 挤掉。
-- 这里强制恢复成原本的全局设置。
vim.opt.signcolumn = "no"
vim.opt.statuscolumn = ""
vim.opt.number = true
