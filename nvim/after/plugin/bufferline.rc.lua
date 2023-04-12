local status, bufferline = pcall(require, "bufferline")
if (not status) then
  print("failed to load bufferline")
  return
end

bufferline.setup({
  options = {
    mode = "tabs",
    always_show_bufferline = false,
    show_buffer_close_icons = true,
    show_close_icon = true,
    color_icons = true,
    offsets = { { filetype = "NvimTree", text = "", padding = 1 } },
  },
})

vim.keymap.set('n', '<Leader><Tab>', '<Cmd>BufferLineCycleNext<CR>', {})
vim.keymap.set('n', '<S-Tab>', '<Cmd>BufferLineCyclePrev<CR>', {})
