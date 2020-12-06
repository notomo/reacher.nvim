local Position = require("reacher/position").Position

local M = {}

local Target = setmetatable({}, Position)
Target.__index = Target
M.Target = Target

function Target.new(row, column, str)
  vim.validate({str = {str, "string"}})
  local tbl = {str = str}
  local position = Position.new(row, column)
  position.__index = position
  return setmetatable(tbl, setmetatable(position, Target))
end

return M
