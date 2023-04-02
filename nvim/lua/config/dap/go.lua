local M = {}

function M.setup()
  require("dap-go").setup()
  vim.keymap.set("n", "<Leader>dt", ":lua require'dap-go'.debug_test()<CR>", { silent = true })
end

return M
