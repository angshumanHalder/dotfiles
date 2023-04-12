local DEBUGGER_PATH = vim.fn.stdpath "data" .. "/site/pack/packer/opt/vscode-js-debug"

-- debug adapters
local dap_status, dap_go = pcall(require, "dap-go")
if not dap_status then
  print("failed to load dap-go")
  return
end



local dap_vscode_js_status, dap_vscode_js = pcall(require, "dap-vscode-js")
if not dap_vscode_js_status then
  print("failed to load dap-vscode-js")
  return
end





-- setups
dap_go.setup()

dap_vscode_js.setup({
  node_path = "node",
  debugger_path = DEBUGGER_PATH,
  adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
})


for _, language in pairs { "typescript", "javascript" } do
  require("dap").configurations[language] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Debug Jest Tests",
      -- trace = true, -- include debugger info
      runtimeExecutable = "node",
      runtimeArgs = {
        "./node_modules/jest/bin/jest.js",
        "--runInBand",
      },
      rootPath = "${workspaceFolder}",
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      internalConsoleOptions = "neverOpen",
    },
  }
end

for _, language in pairs { "typescriptreact", "javascriptreact" } do
  require("dap").configurations[language] = {
    {
      type = "pwa-chrome",
      name = "Attach - Remote Debugging",
      request = "attach",
      program = "${file}",
      cwd = vim.fn.getcwd(),
      sourceMaps = true,
      protocol = "inspector",
      port = 9222,
      webRoot = "${workspaceFolder}",
    },
    {
      type = "pwa-chrome",
      name = "Launch Chrome",
      request = "launch",
      url = "http://localhost:3000",
    },
  }
end

-- keymaps
vim.keymap.set("n", "<Leader>dt", ":lua require'dap-go'.debug_test()<CR>", { silent = true })

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
vim.keymap.set('n', "<Leader>dr", ":lua require'dap'.repl.toggle()<CR>", { silent = true })

-- future reference if required

-- d = {
--   name = "DAP",
--   R = { "<cmd>lua require'dap'.run_to_cursor()<cr>", "Run to Cursor" },
--   E = { "<cmd>lua require'dapui'.eval(vim.fn.input '[Expression] > ')<cr>", "Evaluate Input" },
--   C = { "<cmd>lua require'dap'.set_breakpoint(vim.fn.input '[Condition] > ')<cr>", "Conditional Breakpoint" },
--   U = { "<cmd>lua require'dapui'.toggle()<cr>", "Toggle UI" },
--   b = { "<cmd>lua require'dap'.step_back()<cr>", "Step Back" },
--   e = { "<cmd>lua require'dapui'.eval()<cr>", "Evaluate" },
--   g = { "<cmd>lua require'dap'.session()<cr>", "Get Session" },
--   h = { "<cmd>lua require'dap.ui.widgets'.hover()<cr>", "Hover Variables" },
--   S = { "<cmd>lua require'dap.ui.widgets'.scopes()<cr>", "Scopes" },
--   p = { "<cmd>lua require'dap'.pause.toggle()<cr>", "Pause" },
--   q = { "<cmd>lua require'dap'.close()<cr>", "Quit" },
--   s = { "<cmd>lua require'dap'.continue()<cr>", "Start" },
--   x = { "<cmd>lua require'dap'.terminate()<cr>", "Terminate" },
-- },
