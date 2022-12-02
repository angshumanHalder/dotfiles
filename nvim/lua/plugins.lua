local status, packer = pcall(require, 'packer')
if (not status) then
  print("Packer not installed")
  return
end

vim.cmd [[packadd packer.nvim]]

packer.startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'nvim-lualine/lualine.nvim' -- Statusline
  use 'onsails/lspkind.nvim' -- vscode-like pictograms
  use 'hrsh7th/cmp-cmdline'
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',

  } -- enhanced text highlighting
  use 'windwp/nvim-autopairs' -- auto pairs brackets
  use 'windwp/nvim-ts-autotag' -- xml tags pair
  use 'nvim-lua/plenary.nvim' -- common utilities
  use 'nvim-telescope/telescope.nvim' -- file search with regex file
  use 'nvim-telescope/telescope-file-browser.nvim' -- needs to be included with telescope
  use 'kyazdani42/nvim-web-devicons' -- file icons
  use 'akinsho/nvim-bufferline.lua' -- buffer line for managing buffer with tabs
  use 'norcalli/nvim-colorizer.lua'
  use 'jose-elias-alvarez/null-ls.nvim' -- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua

  use 'lewis6991/gitsigns.nvim'
  use 'dinhhuy258/git.nvim'

  use {
    'nvim-tree/nvim-tree.lua',
    requires = {
      'nvim-tree/nvim-web-devicons', -- optional, for file icons
    },
  }
  use 'lewis6991/impatient.nvim'
  use 'numToStr/Comment.nvim'

  use 'simrat39/rust-tools.nvim'
  use {
    'folke/todo-comments.nvim',
    requires = 'nvim-lua/plenary.nvim',
  } -- todo comments highlighter_only

  use 'unblevable/quick-scope' -- highlight jumpt text
  use 'p00f/nvim-ts-rainbow'

  use 'folke/tokyonight.nvim' -- coloscheme
  use 'ellisonleao/gruvbox.nvim' -- coloscheme,
  use "EdenEast/nightfox.nvim" -- colorscheme

  use 'hrsh7th/cmp-emoji'
  use 'nvim-treesitter/playground'
  use({
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
  })
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

  -- Snippets
  use { 'L3MON4D3/LuaSnip' }
  use { 'rafamadriz/friendly-snippets' }
  use 'glepnir/lspsaga.nvim'
  use { 'sindrets/diffview.nvim', requires = 'nvim-lua/plenary.nvim' }

  -- Debugging
  use 'mfussenegger/nvim-dap'
  use 'leoluz/nvim-dap-go'
  use { "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } }
  use 'theHamsta/nvim-dap-virtual-text'
end)
