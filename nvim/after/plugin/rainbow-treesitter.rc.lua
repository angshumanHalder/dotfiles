local status, rainbow = pcall(require, 'nvim-treesitter.configs')
if (not status) then
  print("failed to load nvim-treesitter.configs")
  return
end

rainbow.setup({
  rainbow = {
    disable = { "html" },
    enable = true,
    extended_mode = false,
    max_file_lines = nil
  },
})
