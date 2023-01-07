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

-- vim.cmd [[colorscheme nordfox]]


local status, catppuccin = pcall(require, 'catppuccin')
if (not status) then print('catppuccin load failed') return end

catppuccin.setup({});
vim.cmd [[colorscheme catppuccin-frappe]]
