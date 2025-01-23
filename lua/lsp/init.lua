-- require("lsp.lsp-installer")
require("lsp.lsp-mason")
require("lsp.nvim-lspconfig")
require'lspconfig'.pylsp.setup {}
require'lspconfig'.gopls.setup {}
require'lspconfig'.lua_ls.setup {}
