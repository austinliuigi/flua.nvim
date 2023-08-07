---@class Config
---@field path string: Path to store flua file
---@field border string: Border type for the floating window. See `:h nvim_open_win` (default: `single`)
---@field blend number: Transparency of the floating window (default: `true`)
---@field dimensions Dimensions: Dimensions of the floating window

local config = {
  path = vim.env.HOME .. "/.local/share/nvim/flua.lua",
  border = "rounded",
  blend = 0,
  dimensions = {
    height = 0.8,
    width = 0.8,
    x = 0.5,
    y = 0.5,
  }
}

return config
