local options = {
  encoding = "utf-8",
  number = true,
  relativenumber = false,
  cursorline = true,
  hlsearch = true,
  ignorecase = true,
  expandtab = true,
  tabstop = 2,
  shiftwidth = 2,
  scrolloff = 8,
  smartcase = true,
  smartindent = true,
  splitbelow = true,
  splitright = true,
  -- showtabline = 2,
  termguicolors = true,
  updatetime = 300,
  backup = false,
  writebackup = false,
  signcolumn = "no",
  clipboard = "unnamedplus",
  showmode = false,
  hidden = true,
}

vim.opt.shortmess:append "c"

for k, v in pairs(options) do
  vim.opt[k] = v
end

-- WSL yank support
vim.cmd [[
let s:clip = '/mnt/c/Windows/System32/clip.exe' 
if executable(s:clip)
    augroup WSLYank
        autocmd!
        autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
    augroup END
endif
]]
