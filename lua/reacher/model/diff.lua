local vim = vim

local M = {}

local Fillers = {}
Fillers.__index = Fillers
M.Fillers = Fillers

function Fillers.new(s, e)
  if not vim.wo.diff then
    local tbl = {_fillers = {}, _first_row = s}
    return setmetatable(tbl, Fillers)
  end

  local fillers = {}
  for row = s, e, 1 do
    local diff_count = vim.fn.diff_filler(row)
    if diff_count ~= 0 then
      table.insert(fillers, {row = row, diff_count = diff_count})
    end
  end

  local tbl = {_fillers = fillers, _first_row = s}
  return setmetatable(tbl, Fillers)
end

function Fillers.apply_offset(self, row)
  local result_row = row
  for _, f in ipairs(self._fillers) do
    if row < f.row then
      return result_row
    end
    result_row = result_row + f.diff_count
  end
  return result_row
end

function Fillers.add_to(self, lines)
  for _, filler in ipairs(vim.fn.reverse(self._fillers)) do
    for _ = 1, filler.diff_count, 1 do
      local i = filler.row - self._first_row + 1
      table.insert(lines, i, {str = "", row = i})
    end
  end
  return lines
end

return M
