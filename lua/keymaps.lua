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
keymap("n", "<Up>", ":resize -2<CR>", opts)
keymap("n", "<Down>", ":resize +2<CR>", opts)
keymap("n", "<Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<Right>", ":vertical resize +2<CR>", opts)

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
keymap("n", "Y", "y$", opts)

-- switch h/cpp
keymap("n", "<A-o>", "<cmd>FSHere<cr>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Better terminal navigation
keymap("t", "<C-k>", "<C-\\><C-n><C-w>k", term_opts)
keymap("t", "<C-j>", "<C-\\><C-n><C-w>j", term_opts)
keymap("t", "<C-h>", "<C-\\><C-n><C-w>h", term_opts)
keymap("t", "<C-l>", "<C-\\><C-n><C-w>l", term_opts)
keymap("t", "<ESC>", "<C-\\><C-n>", term_opts)
keymap("n", "<Leader>t", "<cmd>exe v:count1 . 'ToggleTerm'", opts)

-- telescope
keymap("n", "<Leader>f", "<cmd>lua require('telescope').extensions.live_grep_raw.live_grep_raw(require('telescope.themes').get_ivy())<cr>", opts)
keymap("v", "<Leader>f", "<cmd>lua require('telescope.builtin').grep_string(require('telescope.themes').get_ivy())<cr>", opts)
keymap("n", "<Leader>s", "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", opts)
keymap("n", "<C-p>", "<cmd>Telescope find_files<cr>", opts)


-- session
keymap("n", "gs", "<cmd>SessionManager load_session<cr>", opts)

-- FileExpoler
keymap("n", "tt", "<cmd>NvimTreeToggle<cr>", opts)

-- Spectre
keymap("v", "<Leader>s", "<cmd>lua require('spectre').open_visual()<cr>", opts)

-- lsp
keymap("n", "gr", "<cmd>Trouble lsp_references<cr>", opts)
