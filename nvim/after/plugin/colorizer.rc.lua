local status, colorizer = pcall(require, "colorizer")
if (not status) then
  print("failed to load colorizer")
  return
end

colorizer.setup({
  '*';
})
