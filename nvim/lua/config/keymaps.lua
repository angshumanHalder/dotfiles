-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- replace without yanking to default register
keymap.set("x", "<leader>p", '"_dP')

-- delete function without yanking
keymap.set({ "n", "v" }, "<leader>d", '"_d')

-- I hate escape
keymap.set("i", "jk", "<Esc>")
keymap.set("n", "<C-c>", "<Esc>")

-- New tab
keymap.set("n", "te", ":tabedit<Return>", { silent = true })

-- Split windows
keymap.set("n", "ss", ":split<Return><C-w>w", { silent = true })
keymap.set("n", "sv", ":vsplit<Return><C-w>w", { silent = true })

-- Better window navigation
keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })
keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })

-- Resize window
keymap.set("n", "<Leader><left>", ":vertical resize -2<CR>", { noremap = true, silent = true })
keymap.set("n", "<Leader><right>", ":vertical resize +2<CR>", { noremap = true, silent = true })
keymap.set("n", "<Leader><up>", ":resize +2<CR>", { noremap = true, silent = true })
keymap.set("n", "<Leader><down>", ":resize -2<CR>", { noremap = true, silent = true })

-- TAB completion
vim.cmd([[ inoremap <expr><TAB> pumvisible() ? "<C-n>" : "<TAB>" ]])

-- Stay in indent mode
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")
