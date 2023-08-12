local status, obsidian = pcall(require, "obsidian")
if (not status) then
  print("failed to load obsidian")
  return
end

obsidian.setup({
  dir = "~/Documents/Notes",
  mappings = {
    ["<leader>gf"] = require("obsidian.mapping").gf_passthrough(),
  }
})
