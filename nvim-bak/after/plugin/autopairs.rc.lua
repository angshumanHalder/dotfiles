local status, autopairs = pcall(require, "nvim-autopairs")
if (not status) then
  print("failed to load nvim-autopairs")
  return
end

autopairs.setup({
  disable_filetype = { "TelescopePrompt", "vim" },
})
