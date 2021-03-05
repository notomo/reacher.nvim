local Position = require("reacher.model.position").Position
local Distance = require("reacher.model.distance").Distance
local vim = vim

local M = {}

local Target = setmetatable({}, Position)
Target.__index = Target
M.Target = Target

function Target.new(row, column, column_end, str, is_virtual, matches)
  vim.validate({
    str = {str, "string"},
    column_end = {column_end, "number"},
    is_virtual = {is_virtual, "boolean", true},
    matches = {matches, "table", true},
  })
  local tbl = {
    str = str,
    column_end = column_end,
    _is_virtual = is_virtual or false,
    _matches = matches or {},
  }
  local position = Position.new(row, column)
  position.__index = position
  return setmetatable(tbl, setmetatable(position, Target))
end

function Target.new_virtual(row, column, column_end, str)
  return Target.new(row, column, column_end, str, true)
end

function Target.with(self, matches)
  return Target.new(self.row, self.column, self.column_end, self.str, false, matches)
end

function Target.highlight(self, highlighter, hl_group)
  if not self._is_virtual and #self._matches == 0 then
    highlighter:add(hl_group, self.row - 1, self.column, self.column_end)
  elseif not self._is_virtual then
    for _, range in ipairs(self._matches) do
      highlighter:add(hl_group, self.row - 1, self.column + range[1], self.column + range[2])
    end
  else
    highlighter:add_virtual(hl_group, self.row - 1, self.column, self.column_end, self.str)
  end
end

local Targets = {}
M.Targets = Targets

function Targets.new(targets, index)
  vim.validate({targets = {targets, "table"}, index = {index, "number", true}})
  index = index or 1
  local tbl = {_targets = targets, _index = index}
  return setmetatable(tbl, Targets)
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

function Targets.__index(self, k)
  if type(k) == "number" then
    return self._targets[k]
  end
  return Targets[k]
end

return M
