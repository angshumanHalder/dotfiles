local status, telescope = pcall(require, "telescope")
if (not status) then
  print("failed to load telescope")
  return
end

local actions = require('telescope.actions')
local builtin = require("telescope.builtin")

telescope.setup({
  defaults = {
    prompt_prefix = " ",
    selection_caret = " ",
    path_display = { "smart" },
    mappings = {
      ["i"] = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      },
      n = {
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
  },
  extensions = {
  },
})

telescope.load_extension("fzf")

vim.keymap.set('n', 'FF',
  function()
    builtin.find_files({
      no_ignore = false,
      hidden = true
    })
  end)
vim.keymap.set('n', 'Fg', function()
  builtin.live_grep()
end)
vim.keymap.set('n', 'Fb', function()
  builtin.buffers()
end)
vim.keymap.set('n', 'FT', function()
  builtin.help_tags()
end)
vim.keymap.set('n', 'Fe', function()
  builtin.diagnostics()
end)
vim.keymap.set('n', '<Leader>Fg', '<Cmd>Telescope git_status<CR>', { noremap = true, silent = true })
