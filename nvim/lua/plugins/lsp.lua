return {
  {
    "glepnir/lspsaga.nvim",
    lazy = false,
    config = function()
      require("lspsaga").setup({
        server_filetype_map = {
          typescript = "typescript",
        },
        finder = {
          keys = {
            vsplit = "v",
            split = "s",
          },
        },
      })
    end,
    keys = {
      { "<Leader>ca", "<cmd>Lspsaga code_action<CR>", silent = true, noremap = true },
      { "<Leader>dj", "<Cmd>Lspsaga diagnostic_jump_next<CR>", silent = true, noremap = true },
      { "<Leader>dk", "<Cmd>Lspsaga diagnostic_jump_prev<CR>", silent = true, noremap = true },
      { "<leader>o", "<cmd>Lspsaga outline<CR>", silent = true, noremap = true },
      { "K", "<Cmd>Lspsaga hover_doc<CR>", silent = true, noremap = true },
      { "gf", "<Cmd>Lspsaga finder<CR>", silent = true, noremap = true },
      { "gd", "<cmd>Lspsaga goto_definition<CR>", silent = true, noremap = true },
      { "gp", "<Cmd>Lspsaga peek_definition<CR>", silent = true, noremap = true },
      { "gr", "<Cmd>Lspsaga rename<CR>", silent = true, noremap = true },
    },
  },
  {
    "onsails/lspkind.nvim",
    config = function()
      local protocol = require("vim.lsp.protocol")
      require("lspkind").init({
        -- enables text annotations
        --
        -- default: true
        mode = "symbol",

        -- default symbol map
        -- can be either 'default' (requires nerd-fonts font) or
        -- 'codicons' for codicon preset (requires vscode-codicons font)
        --
        -- default: 'default'
        preset = "codicons",

        -- override preset symbols
        -- default: {}
        symbol_map = {
          Text = "",
          Method = "",
          Function = "",
          Constructor = "",
          Field = "ﰠ",
          Variable = "",
          Class = "ﴯ",
          Interface = "",
          Module = "",
          Property = "ﰠ",
          Unit = "塞",
          Value = "",
          Enum = "",
          Keyword = "",
          Snippet = "",
          Color = "",
          File = "",
          Reference = "",
          Folder = "",
          EnumMember = "",
          Constant = "",
          Struct = "פּ",
          Event = "",
          Operator = "",
          TypeParameter = "",
        },
      })
      protocol.CompletionItemKind = {
        "", -- Text
        "", -- Method
        "", -- Function
        "", -- Constructor
        "", -- Field
        "", -- Variable
        "", -- Class
        "ﰮ", -- Interface
        "", -- Module
        "", -- Property
        "", -- Unit
        "", -- Value
        "", -- Enum
        "", -- Keyword
        "﬌", -- Snippet
        "", -- Color
        "", -- File
        "", -- Reference
        "", -- Folder
        "", -- EnumMember
        "", -- Constant
        "", -- Struct
        "", -- Event
        "ﬦ", -- Operator
        "", -- TypeParameter
      }
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "luacheck",
        "shfmt",
        "typescript-language-server",
        "css-lsp",
        "gopls",
        "goimports",
        "gofumpt",
        "gomodifytags",
        "impl",
        "prettierd",
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    init = function()
      local keys = require("lazyvim.plugins.lsp.keymaps").get()
      keys[#keys + 1] = { "<space>e", false }
      keys[#keys + 1] = { "[d", false }
      keys[#keys + 1] = { "]d", false }
      keys[#keys + 1] = { "<space>q", false }
      keys[#keys + 1] = { "K", false }
      keys[#keys + 1] = { "gi", false }
      keys[#keys + 1] = { "<space>rn", false }
      keys[#keys + 1] = { "<space>ca", false }
      keys[#keys + 1] = { "gr", false }
      keys[#keys + 1] = { "gd", false }
    end,
    opts = {
      server = {
        tsserver = {
          root_dir = function(...)
            return require("lspconfig.util").root_pattern(".git")(...)
          end,
          single_file_support = false,
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "literal",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = false,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
      },
    },
  },
}
