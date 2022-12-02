local dap_go_status, dap_go = pcall(require, 'dap-go')
if (not dap_go_status) then print('dap go failed') return end

dap_go.setup()

-- keymaps
vim.keymap.set("n", "<Leader>dt", ":lua require'dap-go'.debug_test()<CR>", { silent = true })
