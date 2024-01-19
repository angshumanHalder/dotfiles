return {
  { "nvim-treesitter/playground", cmd = "TSPlaygroundToggle" },
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate", opts = {
    ensure_installed = "all",
  } },
}
