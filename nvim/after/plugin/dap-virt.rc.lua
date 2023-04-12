local status, dapVirt = pcall(require, "nvim-dap-virtual-text")
if (not status) then
  print('failed to load nvim-dap-virtual-text')
  return
end

dapVirt.setup({})
