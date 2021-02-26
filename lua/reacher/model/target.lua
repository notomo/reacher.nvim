local Position = require("reacher.model.position").Position
local Distance = require("reacher.model.distance").Distance
local vim = vim

local M = {}

local Target = setmetatable({}, Position)
Target.__index = Target
M.Target = Target

function Target.new(row, column, str, origin_row)
  vim.validate({str = {str, "string"}, origin_row = {origin_row, "number"}})
  local tbl = {str = str, origin_row = origin_row}
  local position = Position.new(row, column)
  position.__index = position
  return setmetatable(tbl, setmetatable(position, Target))
end

function Target.__eq(a, b)
  return a.row == b.row and a.column == b.column
end

local Targets = {}
Targets.__index = function(self, k)
  if type(k) == "number" then
    return self._targets[k]
  end
  return Targets[k]
end
M.Targets = Targets

function Targets.new(targets, index)
  vim.validate({targets = {targets, "table"}, index = {index, "number", true}})
  index = index or 1
  local tbl = {_targets = targets, _index = index}
  return setmetatable(tbl, Targets)
end

function Targets.filter(self, fn)
  vim.validate({fn = {fn, "function"}})
  local targets = vim.tbl_filter(fn, self._targets)
  return Targets.new(targets)
end

function Targets.iter(self)
  return next, self._targets, nil
end

function Targets.current(self)
  return self._targets[self._index]
end

function Targets.first(self)
  return Targets.new(self._targets, 1)
end

function Targets.prev(self)
  local index = ((self._index - 1) % #self._targets - 1) % #self._targets + 1
  return Targets.new(self._targets, index)
end

function Targets.next(self)
  local index = (self._index % #self._targets) + 1
  return Targets.new(self._targets, index)
end

function Targets.last(self)
  return Targets.new(self._targets, #self._targets)
end

function Targets.match(self, position)
  local current_target = self:current()
  if not current_target then
    return Targets.new({})
  end

  local distance = Distance.new(position, current_target)
  local index = 1
  for i, target in self:iter() do
    local d = Distance.new(position, target)
    if d < distance then
      distance = d
      index = i
    end
  end
  return Targets.new(self._targets, index)
end

return M
