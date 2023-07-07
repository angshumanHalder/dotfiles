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

local rainbow_status, rainbow_delimiters = pcall(require, 'rainbow-delimiters')
if (not rainbow_status) then
  print("failed to laod rainbow-delimiters")
  return
end

vim.g.rainbow_delimiters = {
  strategy = {
    [''] = rainbow_delimiters.strategy['global'],
    commonlisp = rainbow_delimiters.strategy['local'],
  },
  query = {
    [''] = 'rainbow-delimiters',
  },
  highlight = {
    'RainbowDelimiterRed',
    'RainbowDelimiterYellow',
    'RainbowDelimiterBlue',
    'RainbowDelimiterOrange',
    'RainbowDelimiterGreen',
    'RainbowDelimiterViolet',
    'RainbowDelimiterCyan',
  },
}

vim.cmd [[highlight RainbowDelimiterRed guifg=#e78284 ctermfg=white]]
vim.cmd [[highlight RainbowDelimiterYellow guifg=#e5c890 ctermfg=white]]
vim.cmd [[highlight RainbowDelimiterBlue guifg=#8caaee ctermfg=white]]
vim.cmd [[highlight RainbowDelimiterOrange guifg=#ef9f76 ctermfg=white]]
vim.cmd [[highlight RainbowDelimiterGreen guifg=#a6d189 ctermfg=white]]
vim.cmd [[highlight RainbowDelimiterViolet guifg=#babbf1 ctermfg=white]]
vim.cmd [[highlight RainbowDelimiterCyan guifg=#81c8be ctermfg=white]]
