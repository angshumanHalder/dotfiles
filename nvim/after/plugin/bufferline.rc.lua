local status, bufferline = pcall(require, "bufferline")
if (not status) then return end

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

-- tokyo night scheme
--[[
{
    separator = {
      fg = '#292e42',
      bg = '#272d47',
    },
    separator_selected = {
      fg = '#292e42',
    },
    background = {
      fg = '#c0caf5',
      bg = '#272d47'
    },
    buffer_selected = {
      fg = '#9d7cd8',
      bold = true,
    },
    fill = {
      bg = '#292e42',
    }
  }
--]]
