local status_ok, worktree = pcall(require, "worktree")
if not status_ok then
  return
end

worktree.setup({
  base_path = "~/.worktrees",
})

local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<leader>wa", "<cmd>WorktreeCreate<cr>", opts)
vim.api.nvim_set_keymap("n", "<leader>ww", "<cmd>WorktreeSwitch<cr>", opts)
