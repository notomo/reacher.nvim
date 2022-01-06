local Position = require("reacher.core.position").Position
local Distance = require("reacher.core.distance").Distance
local vim = vim

local M = {}

local Target = setmetatable({}, Position)
Target.__index = Target
M.Target = Target

function Target.new(window_id, row, column, column_end, display_row, display_column, zindex, str, is_virtual)
  vim.validate({
    window_id = { window_id, "number" },
    str = { str, "string" },
    zindex = { zindex, "number" },
    column_end = { column_end, "number" },
    display_row = { display_row, "number" },
    display_column = { display_column, "number" },
    is_virtual = { is_virtual, "boolean", true },
  })
  local tbl = {
    window_id = window_id,
    str = str,
    zindex = zindex,
    column_end = column_end,
    display_row = display_row,
    display_column = display_column,
    _is_virtual = is_virtual or false,
  }
  local position = Position.new(row, column)
  position.__index = position
  return setmetatable(tbl, setmetatable(position, Target))
end

function Target.new_virtual(window_id, row, column, display_row, display_column, zindex, str)
  return Target.new(window_id, row, column, column + #str - 1, display_row, display_column, zindex, str, true)
end

function Target.highlight(self, highlighter, hl_group)
  if not self._is_virtual then
    highlighter:add(hl_group, self.row - 1, self.column, self.column_end)
  else
    highlighter:add_virtual(hl_group, self.row - 1, self.column, self.column_end - 1, self.str)
  end
end

local Targets = {}
M.Targets = Targets

function Targets.new(targets, index)
  vim.validate({ targets = { targets, "table" }, index = { index, "number", true } })
  index = index or 1
  local tbl = { _targets = targets, _index = index }
  return setmetatable(tbl, Targets)
end

function Targets.iter(self)
  return next, self._targets, nil
end

function Targets.current(self)
  return self._targets[self._index]
end

function Targets.first(self)
  if not self:current() then
    return self
  end

  local index = 1
  local first = self._targets[index]
  for i, target in ipairs(self._targets) do
    if
      target.display_row < first.display_row
      or (target.display_row == first.display_row and target.display_column <= first.display_column)
    then
      first = target
      index = i
    end
  end
  return Targets.new(self._targets, index)
end

function Targets.previous(self)
  local current = self:current()
  if not current then
    return self
  end

  local targets = {}
  for i, target in ipairs(self._targets) do
    if
      target.display_row < current.display_row
      or (target.display_row == current.display_row and target.display_column < current.display_column)
    then
      table.insert(targets, { index = i, target = target })
    end
  end

  if #targets == 0 then
    return self:last()
  end

  table.sort(targets, function(a, b)
    if a.target.display_row ~= b.target.display_row then
      return a.target.display_row > b.target.display_row
    end
    return a.target.display_column > b.target.display_column
  end)
  return Targets.new(self._targets, targets[1].index)
end

function Targets.next(self)
  local current = self:current()
  if not current then
    return self
  end

  local targets = {}
  for i, target in ipairs(self._targets) do
    if
      current.display_row < target.display_row
      or (current.display_row == target.display_row and current.display_column < target.display_column)
    then
      table.insert(targets, { index = i, target = target })
    end
  end

  if #targets == 0 then
    return self:first()
  end

  table.sort(targets, function(a, b)
    if a.target.display_row ~= b.target.display_row then
      return a.target.display_row < b.target.display_row
    end
    return a.target.display_column < b.target.display_column
  end)
  return Targets.new(self._targets, targets[1].index)
end

function Targets.last(self)
  if not self:current() then
    return self
  end

  local index = 1
  local last = self._targets[index]
  for i, target in ipairs(self._targets) do
    if
      last.display_row < target.display_row
      or (last.display_row == target.display_row and last.display_column <= target.display_column)
    then
      last = target
      index = i
    end
  end
  return Targets.new(self._targets, index)
end

function Targets.side_first(self)
  if not self:current() then
    return self
  end
  local index = 1
  local first = self._targets[index]
  for i, target in ipairs(self._targets) do
    if
      target.display_column < first.display_column
      or (target.display_column == first.display_column and target.display_row <= first.display_row)
    then
      first = target
      index = i
    end
  end
  return Targets.new(self._targets, index)
end

function Targets.side_last(self)
  if not self:current() then
    return self
  end
  local index = 1
  local last = self._targets[index]
  for i, target in ipairs(self._targets) do
    if
      last.display_column < target.display_column
      or (last.display_column == target.display_column and last.display_row <= target.display_row)
    then
      last = target
      index = i
    end
  end
  return Targets.new(self._targets, index)
end

function Targets.side_next(self)
  local current = self:current()
  if not current then
    return self
  end

  local targets = {}
  for i, target in ipairs(self._targets) do
    if
      current.display_column < target.display_column
      or (current.display_column == target.display_column and current.display_row < target.display_row)
    then
      table.insert(targets, { index = i, target = target })
    end
  end

  if #targets == 0 then
    return self:side_first()
  end

  table.sort(targets, function(a, b)
    if a.target.display_column ~= b.target.display_column then
      return a.target.display_column < b.target.display_column
    end
    return a.target.display_row < b.target.display_row
  end)
  return Targets.new(self._targets, targets[1].index)
end

function Targets.side_previous(self)
  local current = self:current()
  if not current then
    return self
  end

  local targets = {}
  for i, target in ipairs(self._targets) do
    if
      target.display_column < current.display_column
      or (target.display_column == current.display_column and target.display_row < current.display_row)
    then
      table.insert(targets, { index = i, target = target })
    end
  end

  if #targets == 0 then
    return self:side_last()
  end

  table.sort(targets, function(a, b)
    if a.target.display_column ~= b.target.display_column then
      return a.target.display_column > b.target.display_column
    end
    return a.target.display_row > b.target.display_row
  end)
  return Targets.new(self._targets, targets[1].index)
end

function Targets.match(self, position)
  local current_target = self:current()
  if not current_target then
    return self
  end

  local distance = Distance.new(position, Position.new(current_target.display_row, current_target.display_column))
  local index = 1
  for i, target in self:iter() do
    local d = Distance.new(position, Position.new(target.display_row, target.display_column))
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
