return {
  { "folke/tokyonight.nvim", enabled = false },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      transparent_background = true,
      highlight_overrides = {
        frappe = function(frappe)
          return {
            LineNr = { fg = frappe.surface2 },
          }
        end,
      },
    },
  },
}
