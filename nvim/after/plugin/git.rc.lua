local status, git = pcall(require, "git")
if (not status) then return end

git.setup({
  keymaps = {
    -- Open blame window
    blame = "<Leader>gb",
    -- Open file/folder in git repository
    browse = "<Leader>go",
    -- opens new diff to compare against
    diff = "<Leader>gd",
    -- close diff
    diff_close = "<Leader>gD",
  }
})
