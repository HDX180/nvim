-- require("lsp.lsp-installer")
require("lsp.lsp-mason")
require("lsp.nvim-lspconfig")

-- Neovim 0.11 原生 LSP:server 定义由 nvim-lspconfig 在 runtimepath 的 lsp/ 目录提供,
-- 直接 enable 即可(替代已弃用的 require'lspconfig'.xxx.setup{})。
vim.lsp.enable({ "pylsp", "gopls", "lua_ls", "clangd" })
