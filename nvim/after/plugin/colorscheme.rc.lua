local status, catppuccin = pcall(require, 'catppuccin')
if (not status) then
  print("failed to load catppuccin")
  return
end

catppuccin.setup({});
vim.cmd [[colorscheme catppuccin-frappe]]
