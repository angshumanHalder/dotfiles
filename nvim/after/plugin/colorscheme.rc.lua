-- -- gruvbox
-- local status, gruvbox = pcall(require, 'gruvbox')
-- if (not status) then return end
-- --
-- vim.o.background = "dark" -- or "light" for light mode
-- vim.g.gruvbox_contrast_dark = "hard"
-- --
-- gruvbox.setup({
--   transparent_mode = true,
-- })
-- vim.cmd([[colorscheme gruvbox]])

-- tokyonight
-- require("tokyonight").setup({
--   style = "night", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
--   light_style = "night", -- The theme is used when the background is set to light
--   transparent = false, -- Enable this to disable setting the background color
--   terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
--   styles = {},
--   sidebars = { "qf", "help" }, -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
--   day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
--   hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
--   dim_inactive = false, -- dims inactive windows
--   lualine_bold = false, -- When `true`, section headers in the lualine theme will be bold
-- })
-- vim.cmd [[colorscheme tokyonight]]

-- night fox
-- local status, nightfox = pcall(require, 'nightfox')
-- if (not status) then return end
--
-- nightfox.setup({
--   options = {
--     styles = {
--       comments = "italic"
--     }
--   }
-- })

vim.cmd [[colorscheme nordfox]]
