-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

  return require('packer').startup(function()
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    use 'nvim-treesitter/nvim-treesitter'
    use "romgrk/nvim-treesitter-context" -- show class/function at the top

    use 'nvim-tree/nvim-tree.lua'
    use 'nvim-tree/nvim-web-devicons'
    use "nvim-lualine/lualine.nvim" -- status line

    use 'phaazon/hop.nvim'
    use 'tomtom/tcomment_vim'
    use 'mg979/vim-visual-multi'
    use 'jiangmiao/auto-pairs'

    -- lua基础组件
    use 'nvim-lua/plenary.nvim'

    -- 查找替换
    use 'windwp/nvim-spectre'

    use {
      'nvim-telescope/telescope.nvim',
      requires = {
        { 'nvim-telescope/telescope-live-grep-args.nvim' }
      }
    }
    use "nvim-telescope/telescope-ui-select.nvim"
    use {
      "nvim-telescope/telescope-fzf-native.nvim",
      run = "make",
    }

    -- 折叠代码块
    use {
      'kevinhwang91/nvim-ufo',
      requires = 'kevinhwang91/promise-async'
    }

    -- LSP
    use "williamboman/mason.nvim"
    use "williamboman/mason-lspconfig.nvim"
    use "neovim/nvim-lspconfig"

    use 'hrsh7th/nvim-cmp'
    use "hrsh7th/cmp-buffer" -- buffer completions
    use "hrsh7th/cmp-path" -- path completions
    use "hrsh7th/cmp-cmdline" -- cmdline completions
    use "hrsh7th/cmp-nvim-lsp"

    -- 补全
    use { 'L3MON4D3/LuaSnip' }
    use { 'saadparwaiz1/cmp_luasnip' }
    use 'rafamadriz/friendly-snippets'

    -- better quickfix
    use "folke/trouble.nvim"

    -- session
    use {
      "Shatur/neovim-session-manager",
      commit = 'a0b9d25'
    }

    -- color
    use "morhetz/gruvbox"
    use "rebelot/kanagawa.nvim"
    use "catppuccin/nvim"

    -- 启动页
    use "goolord/alpha-nvim"

    -- bufferline
    -- use {
    --   "akinsho/bufferline.nvim", -- tab
    --   tag = "v1.2.0",
    -- }

    use "akinsho/toggleterm.nvim" -- toggle terminal

    -- move smooth
    -- use 'karb94/neoscroll.nvim'

    -- git 
    -- 显示每一行提交信息
    use 'f-person/git-blame.nvim'

    -- copilot

    -- highlight cursor word
    -- use 'RRethy/vim-illuminate'

  end)
