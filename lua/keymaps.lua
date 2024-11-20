local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap leader key
keymap("", ";", "<Nop>", opts)
vim.g.mapleader = ";"
vim.g.maplocalleader = ";"

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
keymap("n", "<Down>", ":resize -2<CR>", opts)
keymap("n", "<Up>", ":resize +2<CR>", opts)
keymap("n", "<Right>", ":vertical resize -2<CR>", opts)
keymap("n", "<Left>", ":vertical resize +2<CR>", opts)

-- no highlight
keymap("n", "<leader>/", ":nohl<cr>", opts)
-- save buffer
keymap("n", "<leader>w", ":w<cr>", opts)
-- exit cur window
keymap("n", "<leader>q", ":q<cr>", opts)
-- Press kj fast to esc
keymap("i", "kj", "<ESC>", opts)
-- Navigate line
keymap("n", "H", "^", opts)
keymap("n", "L", "$", opts)
keymap("v", "H", "^", opts)
keymap("v", "L", "$", opts)

keymap("n", "U", "<C-r>", opts)
keymap("n", "cp", "ciw<C-r>0<ESC>", opts)
keymap("i", "<C-a>", "<Right>", opts)
keymap("n", "<", "<<", opts)
keymap("n", ">", ">>", opts)

-- Move text up and down
keymap("n", "<A-j>", "<Esc>:m .+1<CR>", opts)
keymap("n", "<A-k>", "<Esc>:m .-2<CR>", opts)

-- switch h/cpp
keymap("n", "<A-o>", "<cmd>ClangdSwitchSourceHeader<cr>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Better terminal navigation
keymap("n", "<Leader>t", "<cmd>exe v:count1 . 'ToggleTerm'", opts)
keymap("n", "<Leader>g", "<cmd>lua _lazygit_toggle()<CR>", opts)

-- telescope
keymap("v", "<leader>v", "<cmd>lua require('telescope-live-grep-args.shortcuts').grep_visual_selection()<cr>", opts)
keymap("v", "<leader>f", "<cmd>lua require('telescope-live-grep-args.shortcuts').grep_word_under_cursor({additional_args = function() return { '-w', '-s' } end})<cr>", opts)
keymap("n", "<leader>f", "<cmd>lua require('telescope.builtin').grep_string({ shorten_path = true, word_match = '-w', only_sort_text = true, search = '' })<cr>", opts)
-- keymap('n', '<leader>f', "<cmd>lua require('telescope.builtin').live_grep()<cr>", opts)
keymap("n", "<Leader>s", "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", opts)
keymap("n", "<C-p>", "<cmd>Telescope find_files<cr>", opts)

-- lsp
keymap("n", "gd", "<cmd>Telescope lsp_definitions theme=ivy<CR>", opts)
keymap("n", "gh", "<cmd>lua vim.lsp.buf.hover()<CR>", opts)
keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)
keymap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
keymap("n", "gr", "<cmd>Telescope lsp_references theme=ivy<CR>", opts)
keymap("n", "g]", "<cmd>lua vim.diagnostic.goto_next({ border = \"rounded\" })<CR>", opts)
keymap("n", "g[", "<cmd>lua vim.diagnostic.goto_prev({ border = \"rounded\" })<CR>", opts)
vim.cmd [[ command! Format execute 'lua vim.lsp.buf.format()' ]]

-- fold

-- session
keymap("n", "gs", "<cmd>SessionManager load_session<cr>", opts)

-- FileExpoler
keymap("n", "tt", "<cmd>NvimTreeToggle<cr>", opts)

-- Spectre
keymap("v", "<Leader>s", "<cmd>lua require('spectre').open_visual()<cr>", opts)

-- snippets
keymap("s", "<Tab>", "<cmd> lua require('luasnip').jump(1)<cr>", opts)
keymap("s", "<S-Tab>", "<cmd> lua require('luasnip').jump(-1)<cr>", opts)


