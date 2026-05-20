-- use 'nvim-lualine/lualine.nvim' -- Statusline
use("jose-elias-alvarez/null-ls.nvim") -- Use Neovim as a language server to inject LSP diagnostics, code actions, and more via Lua

use("hrsh7th/cmp-emoji")
use({
  "iamcco/markdown-preview.nvim",
  run = function()
    vim.fn["mkdp#util#install"]()
  end,
})

-- -- Debugging
use("mfussenegger/nvim-dap")
use("leoluz/nvim-dap-go")
use({ "rcarriga/nvim-dap-ui", requires = { "mfussenegger/nvim-dap" } })
use("theHamsta/nvim-dap-virtual-text")
use({
  "mxsdev/nvim-dap-vscode-js",
  requires = {
    "mfussenegger/nvim-dap",
    {
      "microsoft/vscode-js-debug",
      opt = true,
      run = "npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out",
    },
  },
})

use({ "epwalsh/obsidian.nvim" })
