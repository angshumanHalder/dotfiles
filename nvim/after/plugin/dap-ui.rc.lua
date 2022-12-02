local dap_status, dap = pcall(require, "dap")
if (not dap_status) then print('dap require failed') return end

local status, dapui = pcall(require, "dapui")
if (not status) then print('dapui require failed') return end


dapui.setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open({})
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close({})
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close({})
end
