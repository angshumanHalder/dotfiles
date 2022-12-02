local keymap = vim.keymap

-- Increment/decrement
keymap.set('n', '+', '<C-a>')
keymap.set('n', '-', '<C-x>')

-- I hate escape
keymap.set('i', 'jk', '<Esc>')
keymap.set('n', '<C-c>', '<Esc>')

-- New tab
keymap.set('n', 'te', ':tabedit<Return>', { silent = true })

-- Split windows
keymap.set('n', 'ss', ':split<Return><C-w>w', { silent = true })
keymap.set('n', 'sv', ':vsplit<Return><C-w>w', { silent = true })
keymap.set('n', '<Leader>d', ':bp | bd #<CR>', { silent = true })

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

-- Nvim tree
keymap.set("n", "<Leader>e", ":NvimTreeToggle<Return>", { noremap = true, silent = true })

-- TAB completion
vim.cmd([[ inoremap <expr><TAB> pumvisible() ? "<C-n>" : "<TAB>" ]])

-- Stay in indent mode
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- debuggin
vim.keymap.set('n', "<F5>", ":lua require'dap'.continue()<CR>", { silent = true })
vim.keymap.set('n', "<S-F5>", ":lua require'dap'.disconnect()<CR>", { silent = true })
vim.keymap.set('n', "<F10>", ":lua require'dap'.step_over()<CR>", { silent = true })
vim.keymap.set('n', "<F11>", ":lua require'dap'.step_into()<CR>", { silent = true })
vim.keymap.set('n', "<F12>", ":lua require'dap'.step_out()<CR>", { silent = true })
vim.keymap.set('n', "<Leader>b", ":lua require'dap'.toggle_breakpoint()<CR>", { silent = true })
vim.keymap.set('n', "<Leader>B", ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
  { silent = true })
vim.keymap.set('n', "<Leader>lp", ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>",
  { silent = true })
vim.keymap.set('n', "<Leader>dr", ":lua require'dap'.repl.open()<CR>", { silent = true })
