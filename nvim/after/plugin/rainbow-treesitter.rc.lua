local status, rainbow = pcall(require, 'nvim-treesitter.configs')
if (not status) then return end

rainbow.setup({
  rainbow = {
    enable = true,
    extended_mode = false
  },
  max_file_lines = nil
})
