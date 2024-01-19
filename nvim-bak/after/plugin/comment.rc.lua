local status, comment = pcall(require, "Comment")
if (not status) then
  print("failed to load comment")
  return
end

comment.setup()
