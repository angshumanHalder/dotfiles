require('angshuman.base')
require('angshuman.highlights')
require('angshuman.plugins')
require('angshuman.maps')

local has = function(x)
  return vim.fn.has(x) == 1
end

local is_mac = has "macunix"
local is_win = has "win32"

if is_mac then
  require('angshuman.macos')
end
if is_win then
  require('angshuman.windows')
end
