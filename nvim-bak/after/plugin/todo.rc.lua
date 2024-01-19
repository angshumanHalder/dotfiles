local status, todo = pcall(require, 'todo-comments')
if (not status) then
  print("failed to load todo-comments")
  return
end

todo.setup({})

vim.keymap.set("n", "<leader>Ft", "<Cmd>TodoTelescope<CR>", { noremap = true, silent = true })
