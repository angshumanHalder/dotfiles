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
      { "<Leader>ca", "<cmd>Lspsaga code_action<CR>" },
      { "<Leader>dj", "<Cmd>Lspsaga diagnostic_jump_next<CR>" },
      { "<Leader>dk", "<Cmd>Lspsaga diagnostic_jump_prev<CR>" },
      { "<leader>o", "<cmd>Lspsaga outline<CR>" },
      { "K", "<Cmd>Lspsaga hover_doc<CR>" },
      { "gf", "<Cmd>Lspsaga finder<CR>" },
      { "gd", "<cmd>Lspsaga goto_definition<CR>" },
      { "gp", "<Cmd>Lspsaga peek_definition<CR>" },
      { "gr", "<Cmd>Lspsaga rename<CR>" },
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