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
  updatetime = 500,
  backup = false,
  writebackup = false,
  signcolumn = "no",
  clipboard = "unnamedplus",
  showmode = false,
  hidden = true,
  mouse = "",
}

vim.opt.shortmess:append "c"

for k, v in pairs(options) do
  vim.opt[k] = v
end

vim.cmd [[
  highlight TreesitterContextBottom cterm=NONE ctermbg=235 gui=NONE guisp=NONE guibg=#303347
  highlight TreesitterContextLineNumberBottom cterm=NONE ctermbg=235 gui=NONE guisp=NONE guibg=#303347
]]

-- 高亮cursor下的word
vim.api.nvim_create_autocmd({'CursorHold', 'CursorHoldI'}, {
  callback = function(opts)
    vim.lsp.buf.document_highlight()
  end
})

vim.api.nvim_create_autocmd({'CursorMoved'}, {
  callback = function(opts)
    vim.lsp.buf.clear_references()
  end
})
