local status, gitsigns = pcall(require, "gitsigns")
if (not status) then return end

gitsigns.setup({
  current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`

})

vim.keymap.set('n', '<leader>hc', function()
  if vim.wo.diff then return '<leader>hc' end
  vim.schedule(function() gitsigns.next_hunk() end)
  return '<Ignore>'
end, { expr = true })

vim.keymap.set('n', '<leader>hc', function()
  if vim.wo.diff then return '<leader>hc' end
  vim.schedule(function() gitsigns.prev_hunk() end)
  return '<Ignore>'
end, { expr = true })

vim.keymap.set({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>')
vim.keymap.set({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>')
vim.keymap.set('n', '<leader>hS', gitsigns.stage_buffer)
vim.keymap.set('n', '<leader>ha', gitsigns.stage_hunk)
vim.keymap.set('n', '<leader>hu', gitsigns.undo_stage_hunk)
vim.keymap.set('n', '<leader>hR', gitsigns.reset_buffer)
vim.keymap.set('n', '<leader>hp', gitsigns.preview_hunk)
vim.keymap.set('n', '<leader>hb', function() gitsigns.blame_line { full = true } end)
vim.keymap.set('n', '<leader>hd', gitsigns.diffthis)
vim.keymap.set('n', '<leader>hD', function() gitsigns.diffthis('~') end)
vim.keymap.set('n', '<leader>td', gitsigns.toggle_deleted)
