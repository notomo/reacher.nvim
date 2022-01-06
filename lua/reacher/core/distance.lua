local vim = vim

local M = {}

local Distance = {}
Distance.__index = Distance
M.Distance = Distance

function Distance.new(p1, p2)
  vim.validate({ p1 = { p1, "table" }, p2 = { p2, "table" } })
  local tbl = { x = math.abs(p1.column - p2.column), y = math.abs(p1.row - p2.row) }
  return setmetatable(tbl, Distance)
end

function Distance.__eq(a, b)
  return a.y == b.y and a.x == b.x
end

function Distance.__lt(a, b)
  return a.y < b.y or (a.y == b.y and a.x < b.x)
end

function Distance.__le(a, b)
  return Distance.__lt(a, b) or Distance.__eq(a, b)
end

return M
