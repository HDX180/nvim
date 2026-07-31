-- require("lsp.lsp-installer")
require("lsp.lsp-mason")
require("lsp.nvim-lspconfig")

-- Neovim 0.11 原生 LSP:server 定义由 nvim-lspconfig 在 runtimepath 的 lsp/ 目录提供,
-- 直接 enable 即可(替代已弃用的 require'lspconfig'.xxx.setup{})。
vim.lsp.enable({ "pylsp", "gopls", "lua_ls", "clangd" })

-- clangd 的 switchSourceHeader 扩展方法。原来由 nvim-lspconfig 注册命令,
-- 迁移到原生 vim.lsp.enable 后需自行提供,供 <A-o> 使用。
local function switch_source_header(bufnr)
  bufnr = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })[1]
  if not client then
    vim.notify("No active clangd client on the current buffer", vim.log.levels.ERROR)
    return
  end
  local params = vim.lsp.util.make_text_document_params(bufnr)
  client:request("textDocument/switchSourceHeader", params, function(err, result)
    if err then
      vim.notify("switchSourceHeader failed: " .. tostring(err), vim.log.levels.ERROR)
      return
    end
    if not result then
      vim.notify("Corresponding source/header file not found", vim.log.levels.WARN)
      return
    end
    vim.cmd.edit(vim.uri_to_fname(result))
  end, bufnr)
end

vim.api.nvim_create_user_command("ClangdSwitchSourceHeader", function()
  switch_source_header(0)
end, { desc = "Switch between clangd source/header file" })
