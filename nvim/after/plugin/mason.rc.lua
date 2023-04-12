local status, mason = pcall(require, "mason")
if (not status) then
  print("failed to load mason")
  return
end

local status2, lspconfig = pcall(require, "mason-lspconfig")
if (not status2) then
  print("failed to load mason-lspconfig")
  return
end

mason.setup()
lspconfig.setup()

lspconfig.setup {
  automatic_installation = true
}
