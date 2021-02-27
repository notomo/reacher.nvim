local vim = vim

local M = {}

local Folds = {}
Folds.__index = Folds
M.Folds = Folds

function Folds.new(s, e, fillers)
  vim.validate({s = {s, "number"}, e = {e, "number"}, fillers = {fillers, "table"}})
  local tbl = {_folds = {}}
  local self = setmetatable(tbl, Folds)

  if not vim.wo.foldenable then
    return self
  end

  local row = s
  while row <= e do
    local end_row = vim.fn.foldclosedend(row)
    if end_row ~= -1 then
      local offset = fillers:offset(row)
      table.insert(self._folds, {row + offset - s + 1, end_row + offset - s + 1})
      row = end_row + 1
    else
      row = row + 1
    end
  end

  return self
end

function Folds.execute(self)
  for _, range in ipairs(self._folds) do
    vim.cmd(("%d,%dfold"):format(range[1], range[2]))
  end
end

function Folds.apply_to(self, lines)
  for _, row in self:_rows() do
    lines[row].str = ""
  end
  return lines
end

function Folds.exists(self)
  return #self._folds > 0
end

function Folds._rows(self)
  local rows = {}
  for _, range in ipairs(self._folds) do
    for i = range[1], range[2], 1 do
      table.insert(rows, i)
    end
  end
  return ipairs(rows)
end

return M
