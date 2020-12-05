local M = {}

local Distance = {}
Distance.__index = Distance
M.Distance = Distance

function Distance.new(p1, p2)
  local tbl = {x = math.abs(p1.row - p2.row), y = math.abs(p1.column - p2.column)}
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
