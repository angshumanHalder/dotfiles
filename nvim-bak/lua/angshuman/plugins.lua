local status, packer = pcall(require, 'packer')
if (not status) then
  print("Packer not installed")
  return
end

vim.cmd [[packadd packer.nvim]]

packer.startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'nvim-lualine/lualine.nvim' -- Statusline
  use 'onsails/lspkind.nvim'      -- vscode-like pictograms
  use 'hrsh7th/cmp-cmdline'
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
  }                                     -- enhanced text highlighting
  use 'windwp/nvim-autopairs'           -- auto pairs brackets
  use 'windwp/nvim-ts-autotag'          -- xml tags pair
  use 'nvim-lua/plenary.nvim'           -- common utilities
  use 'nvim-telescope/telescope.nvim'   -- file search with regex file
  use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
  use 'kyazdani42/nvim-web-devicons'    -- file icons
  use 'akinsho/nvim-bufferline.lua'     -- buffer line for managing buffer with tabs
  use 'norcalli/nvim-colorizer.lua'
  use 'jose-elias-alvarez/null-ls.nvim' -- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua

  use 'tpope/vim-fugitive'
  use 'lewis6991/gitsigns.nvim'

  use {
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons', -- optional, for file icons
    },
    commit = "3c4958ab3dd0e5fa470fb50b6b9cc6df48229a2e"
  }
  use 'numToStr/Comment.nvim'

  use 'simrat39/rust-tools.nvim'
  use {
    'folke/todo-comments.nvim',
    requires = 'nvim-lua/plenary.nvim',
  }                            -- todo comments highlighter_only

  use 'unblevable/quick-scope' -- highlight jumpt text

  use { "catppuccin/nvim", as = "catppuccin" }

  use 'hrsh7th/cmp-emoji'
  use 'nvim-treesitter/playground'
  use {
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
  }
  -- LSP Support
  use { 'neovim/nvim-lspconfig' }
  use { 'williamboman/mason.nvim' }
  use { 'williamboman/mason-lspconfig.nvim' }

  -- Autocompletion
  use { 'hrsh7th/nvim-cmp' }
  use { 'hrsh7th/cmp-buffer' }
  use { 'hrsh7th/cmp-path' }
  use { 'saadparwaiz1/cmp_luasnip' }
  use { 'hrsh7th/cmp-nvim-lsp' }
  use { 'hrsh7th/cmp-nvim-lua' }

  -- -- Snippets
  use { 'L3MON4D3/LuaSnip' }
  use { 'rafamadriz/friendly-snippets' }
  use { "glepnir/lspsaga.nvim" }
  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }

  -- -- Debugging
  use "mfussenegger/nvim-dap"
  use 'leoluz/nvim-dap-go'
  use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }
  use 'theHamsta/nvim-dap-virtual-text'
  use { "mxsdev/nvim-dap-vscode-js",
    requires = {
      "mfussenegger/nvim-dap",
      {
        "microsoft/vscode-js-debug",
        opt = true,
        run = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
      }
    },
  }

  use {
    "kevinhwang91/nvim-ufo",
    requires = 'kevinhwang91/promise-async'
  }
  use { "HiPhish/rainbow-delimiters.nvim" }

  use { "epwalsh/obsidian.nvim" }
end)
