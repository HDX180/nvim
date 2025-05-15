local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup {

  { "nvim-treesitter/nvim-treesitter" },
  -- 显示类/函数
  { "romgrk/nvim-treesitter-context" },

  { "nvim-tree/nvim-tree.lua" },
  -- icons
  { "nvim-tree/nvim-web-devicons" },
  {
    "echasnovski/mini.icons",
    version = '*',
    opts = {},
    lazy = true,
    specs = {
      { "nvim-tree/nvim-web-devicons", enabled = false, optional = true },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
  { "nvim-lualine/lualine.nvim" },

  { "phaazon/hop.nvim" },
  { "numToStr/Comment.nvim" },
  { "mg979/vim-visual-multi" },
  { "jiangmiao/auto-pairs" },

  -- lua基础组件
  { "nvim-lua/plenary.nvim" },

  -- 查找替换
  { "windwp/nvim-spectre" },

  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-telescope/telescope-live-grep-args.nvim",
      "nvim-telescope/telescope-symbols.nvim",
      "nvim-telescope/telescope-fzf-native.nvim",
    },
  },

  { "stevearc/dressing.nvim" },

  -- LSP
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "neovim/nvim-lspconfig" },

  -- 自动补全
  {
    "hrsh7th/nvim-cmp",
    event = 'VeryLazy',
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-omni",
      "hrsh7th/cmp-emoji",
      "hrsh7th/cmp-cmdline",
      "onsails/lspkind.nvim",
    },
  },

  -- better quickfix
  { "folke/trouble.nvim" },

  -- session_manager
  { "Shatur/neovim-session-manager" },
  -- auto_session

  -- colorscheme
  { "morhetz/gruvbox" },
  { "rebelot/kanagawa.nvim" },
  { "catppuccin/nvim" },


  { "akinsho/toggleterm.nvim" },

  -- move smooth
  { "karb94/neoscroll.nvim" },

  -- git
  -- 显示每一行提交信息
  { "f-person/git-blame.nvim" },

  -- copilot
  {
    dir = "~/.config/nvim/pack/gongfeng/start/vim"
  },

  {
    "olimorris/codecompanion.nvim",
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "codecompanion" },
  },

  -- 代码缩进线
  { "lukas-reineke/indent-blankline.nvim" },
}
