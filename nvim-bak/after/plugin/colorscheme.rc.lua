local status, catppuccin = pcall(require, 'catppuccin')
if (not status) then
  print("failed to load catppuccin")
  return
end

catppuccin.setup({
  transparent_background = true,
  highlight_overrides = {
    frappe = function(frappe)
      return {
        LineNr = { fg = frappe.surface2 }
      }
    end
  }
});

vim.cmd [[colorscheme  catppuccin-frappe]]
