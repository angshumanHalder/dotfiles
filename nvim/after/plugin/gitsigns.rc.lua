local status, gitsigns = pcall(require, "gitsigns")
if (not status) then return end

gitsigns.setup({
  current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
})
