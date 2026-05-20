return {
  { "folke/which-key.nvim", enabled = true },
  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/Documents/Notes",
        },
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`

        on_attach = function(buffer)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
          end

          map({ "n", "v" }, "<leader>hs", gs.stage_hunk)
          map({ "n", "v" }, "<leader>hr", gs.reset_hunk)
          map("n", "<leader>hS", gs.stage_buffer)
          map("n", "<leader>hu", gs.undo_stage_hunk)
          map("n", "<leader>hR", gs.reset_buffer)
          map("n", "<leader>hp", gs.preview_hunk)
          map("n", "<leader>hb", function()
            gs.blame_line({ full = true })
          end)
          map("n", "<leader>hd", gs.diffthis)
          map("n", "<leader>hD", function()
            gs.diffthis("~")
          end)
          map("n", "<leader>td", gs.toggle_deleted)
        end,
      })
    end,
    keys = {
      {
        "<leader>]c",
        function()
          if vim.wo.diff then
            return "<leader>hn"
          end
          vim.schedule(function()
            require("gitsigns").nav_hunk("next")
          end)
          return "<Ignore>"
        end,
        { expr = true },
      },

      {
        "<leader>[c",
        function()
          if vim.wo.diff then
            return "<leader>hc"
          end
          vim.schedule(function()
            require("gitsigns").nav_hunk("prev")
          end)
          return "<Ignore>"
        end,
        { expr = true },
      },
    },
  },
  "tpope/vim-fugitive",
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>xd", "<cmd>DiffviewOpen<cr>", silent = true, noremap = true },
      { "<leader>xc", "<cmd>DiffviewClose<cr>", silent = true, noremap = true },
    },
  },
  { "folke/flash.nvim", enabled = false },
  { "RRethy/vim-illuminate", enabled = false },
  { "nvim-mini/mini.bufremove", enabled = false },
  {
    "unblevable/quick-scope",
    config = function()
      vim.cmd([[highlight QuickScopePrimary guifg='#00C7DF' gui=underline ctermfg=155 cterm=underline]])
      vim.cmd([[highlight QuickScopeSecondary guifg='#afff5f' gui=underline ctermfg=81 cterm=underline]])
    end,
  },
  { "nvim-pack/nvim-spectre", enabled = false },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function(_, _)
      local fzf = require("fzf-lua")
      local actions = fzf.actions
      return {
        files = {
          cwd_prompt = false,
          actions = {
            ["ctrl-i"] = { actions.toggle_ignore },
            ["ctrl-h"] = { actions.toggle_hidden },
          },
        },
        grep = {
          actions = {
            ["ctrl-i"] = { actions.toggle_ignore },
            ["ctrl-h"] = { actions.toggle_hidden },
          },
        },
      }
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- optional, for file icons
    },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", noremap = true, silent = true, { desc = "Toggle NvimTree" } },
    },
    config = function()
      local function my_on_attach(bufnr)
        local api = require("nvim-tree.api")

        local function opts(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        -- default mappings
        api.config.mappings.default_on_attach(bufnr)

        -- custom mappings
        vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
        vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
        vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
        vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
        vim.keymap.set("n", "s", api.node.open.horizontal, opts("Open: Horizontal Split"))
      end

      require("nvim-tree").setup({
        on_attach = my_on_attach,
        update_focused_file = {
          enable = true,
        },
        renderer = {
          root_folder_modifier = ":t",
          icons = {
            glyphs = {
              default = "",
              symlink = "",
              folder = {
                arrow_open = "",
                arrow_closed = "",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
                symlink = "",
                symlink_open = "",
              },
              git = {
                unstaged = "",
                staged = "S",
                unmerged = "",
                renamed = "➜",
                untracked = "U",
                deleted = "",
                ignored = "◌",
              },
            },
          },
        },
        diagnostics = {
          enable = true,
          show_on_dirs = true,
          icons = {
            hint = "",
            info = "",
            warning = "",
            error = "",
          },
        },
        view = {
          width = 30,
          side = "left",
        },
      })
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },
}
