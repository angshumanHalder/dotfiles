local status, fidget = pcall(require, "fidget")
if (not status) then
  print("failed to load fidget")
  return
end

fidget.setup({
  window = {
    blend = 0
  }
})