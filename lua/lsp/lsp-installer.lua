-- https://github.com/williamboman/nvim-lsp-installer
local status_ok, lsp_installer_servers = pcall(require, "nvim-lsp-installer")
if not status_ok then
  vim.notify("nvim-lspconfig not found!")
  return
end
-- WARN: 手动书写 LSP 配置文件
-- 名称：https://github.com/williamboman/nvim-lsp-installer#available-lsps
-- 配置：https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
local servers = {
    -- 语言服务器名称：配置选项
    'sumneko_lua',
    'ccls'
}
local keymap_opts = { noremap=true, silent=true }
-- 这里是 LSP 服务启动后的按键加载
local on_attach = function(_, bufnr)
    -- 跳转到定义（代替内置 LSP 的窗口，telescope 插件让跳转定义更方便）
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>Telescope lsp_definitions theme=ivy<CR>", keymap_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>", keymap_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "g[", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>', keymap_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "g]", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>', keymap_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", keymap_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gr", "<cmd>Telescope lsp_references theme=ivy<CR>", keymap_opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gl", '<cmd>lua vim.diagnostic.open_float()<CR>', keymap_opts)
    vim.cmd [[ command! Format execute 'lua vim.lsp.buf.formatting()' ]]
end

local lsp_server_opts = {
  on_attach = on_attach,
  flags = {
    debounce_text_changes = 150,
  }
}

-- 启动
for _, server_name in pairs(servers) do
    local is_find, server = lsp_installer_servers.get_server(server_name)
    if is_find then
        if not server:is_installed() then
          server:setup(lsp_server_opts)
        end
        -- 判断服务是否准备就绪，若就绪则启动服务
        server:on_ready(
            function()
                server:setup(lsp_server_opts)
            end
        )
    end
end
