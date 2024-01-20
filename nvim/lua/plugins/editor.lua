return {
  { "folke/which-key.nvim", enabled = false },
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
          map("n", "<leader>ha", gs.stage_hunk)
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
            require("gitsigns").next_hunk()
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
            require("gitsigns").prev_hunk()
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
      { "<leader>dv", "<cmd>DiffviewOpen<cr>", silent = true, noremap = true },
      {
        "<leader>dc",
        "<cmd>set hidden<cr> <cmd>DiffviewClose<cr> <cmd>set nohidden<cr>",
        silent = true,
        noremap = true,
      },
    },
  },
  { "folke/flash.nvim", enabled = false },
  { "RRethy/vim-illuminate", enabled = false },
  { "echasnovski/mini.bufremove", enabled = false },
  {
    "unblevable/quick-scope",
    config = function()
      vim.cmd([[highlight QuickScopePrimary guifg='#00C7DF' gui=underline ctermfg=155 cterm=underline]])
      vim.cmd([[highlight QuickScopeSecondary guifg='#afff5f' gui=underline ctermfg=81 cterm=underline]])
    end,
  },
  { "nvim-pack/nvim-spectre", enabled = false },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      "nvim-telescope/telescope-file-browser.nvim",
    },
    keys = {
      {
        "FF",
        function()
          require("telescope.builtin").find_files({
            no_ignore = false,
            hidden = true,
          })
        end,
        desc = "Lists files in your current working directory, respects .gitignore",
      },
      {
        "Fg",
        function()
          require("telescope.builtin").live_grep()
        end,
      },
      {
        "Fb",
        function()
          require("telescope.builtin").buffers()
        end,
        desc = "Lists open buffers",
      },
      {
        "FT",
        function()
          require("telescope.builtin").help_tags()
        end,
      },
      {
        "Fe",
        function()
          require("telescope.builtin").diagnostics()
        end,
      },
      {
        "<Leader>Fg",
        "<Cmd>Telescope git_status<CR>",
        silent = true,
        noremap = true,
      },
      { "<Leader>dl", "<Cmd>Telescope diagnostics<CR>" },
    },
    config = function(_, opts)
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local fb_actions = require("telescope").extensions.file_browser.actions

      opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "smart" },
        wrap_results = true,
        layout_strategy = "horizontal",
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
        mappings = {
          i = {
            ["<C-j>"] = actions.move_selection_next,
            ["<C-k>"] = actions.move_selection_previous,
          },
          n = {
            ["N"] = fb_actions.create,
            ["h"] = fb_actions.goto_parent_dir,
            ["q"] = actions.close,

            ["j"] = actions.move_selection_next,
            ["k"] = actions.move_selection_previous,
            ["H"] = actions.move_to_top,
            ["M"] = actions.move_to_middle,
            ["L"] = actions.move_to_bottom,

            ["gg"] = actions.move_to_top,
            ["G"] = actions.move_to_bottom,
          },
        },
      })
      opts.pickers = {
        diagnostics = {
          theme = "ivy",
          initial_mode = "normal",
          layout_config = {
            preview_cutoff = 9999,
          },
        },
      }
      opts.extensions = {
        file_browser = {
          theme = "dropdown",
          -- disables netrw and use telescope-file-browser in its place
          hijack_netrw = true,
        },
      }
      telescope.setup(opts)
      require("telescope").load_extension("fzf")
      require("telescope").load_extension("file_browser")
      telescope.load_extension("fzf")
    end,
  },
  {
    "s1n7ax/nvim-window-picker",
    name = "window-picker",
    event = "VeryLazy",
    config = function()
      require("window-picker").setup({
        selection_chars = "ABCDEFG;CMRUEIWOQP",
        show_prompt = false,
        hint = "floating-big-letter",
      })
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    keys = {
      { "<Leader>e", "<Cmd>Neotree toggle<CR>" },
    },
    opts = {
      filesystem = {
        filtered_items = {
          visible = true,
          show_hidden_count = true,
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = {
            -- '.git',
            -- '.DS_Store',
            -- 'thumbs.db',
          },
          never_show = {},
        },
      },
      window = {
        mappings = {
          ["o"] = "open",
          ["<cr>"] = "open_with_window_picker",
          ["l"] = "open_with_window_picker",
          ["h"] = "close_node",
          ["s"] = "open_split",
          ["v"] = "open_vsplit",
        },
      },
    },
  },
  {
    "folke/trouble.nvim",
    cmd = { "TroubleToggle", "Trouble" },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle<cr>", silent = true, noremap = true },
      { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", silent = true, noremap = true },
      { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", silent = true, noremap = true },
      { "<leader>xl", "<cmd>TroubleToggle loclist<cr>", silent = true, noremap = true },
      { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", silent = true, noremap = true },
      { "gR", "<cmd>TroubleToggle lsp_references<cr>", silent = true, noremap = true },
    },
  },
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>Ft", "<Cmd>TodoTelescope<CR>", noremap = true, silent = true },
    },
  },
}
