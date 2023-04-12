local status, ufo = pcall(require, "ufo")
if not status then
  print("failed to load nvim-ufo")
end

ufo.setup({
  provider_selector = function()
    return { 'treesitter', 'indent', }
  end
})


vim.keymap.set("n", "zR", require("ufo").openAllFolds)
vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
