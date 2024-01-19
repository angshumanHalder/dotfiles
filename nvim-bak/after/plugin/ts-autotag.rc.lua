local status, autotag = pcall(require, "nvim-ts-autotag")
if (not status) then
  print("failed to load nvim-ts-autotag")
  return
end

autotag.setup()
