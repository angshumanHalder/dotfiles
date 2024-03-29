local status, saga = pcall(require, "lspsaga")
if (not status) then return end

saga.setup({
  server_filetype_map = {
    typescript = 'typescript',
  },
  finder = {
    keys = {
      vsplit = 'v',
      split = 's',
    }
  }
})

local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<Leader>ca', '<cmd>Lspsaga code_action<CR>', { silent = true })
vim.keymap.set('n', '<Leader>dj', '<Cmd>Lspsaga diagnostic_jump_next<CR>', opts)
vim.keymap.set('n', '<Leader>dk', '<Cmd>Lspsaga diagnostic_jump_prev<CR>', opts)
vim.keymap.set('n', '<Leader>dl', '<Cmd>Telescope diagnostics<CR>', opts)
vim.keymap.set("n", "<leader>o", "<cmd>Lspsaga outline<CR>", opts)
vim.keymap.set('n', 'K', '<Cmd>Lspsaga hover_doc<CR>', opts)
vim.keymap.set('n', 'gf', '<Cmd>Lspsaga lsp_finder<CR>', opts)
vim.keymap.set("n", 'gd', "<cmd>Lspsaga goto_definition<CR>", opts)
vim.keymap.set('i', '<C-K>', '<Cmd>Lspsaga signature_help<CR>', opts)
vim.keymap.set('n', 'gp', '<Cmd>Lspsaga peek_definition<CR>', opts)
vim.keymap.set('n', 'gr', '<Cmd>Lspsaga rename<CR>', opts)
