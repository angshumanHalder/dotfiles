local status, dapVirt = pcall(require, "nvim-dap-virtual-text")
if (not status) then print('require failed nvim-dap-virtual-text') return end

dapVirt.setup({})
