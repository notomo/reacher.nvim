local vim = vim

local M = {}

local Fillers = {}
Fillers.__index = Fillers
M.Fillers = Fillers

function Fillers.new(s, e)
  vim.validate({s = {s, "number"}, e = {e, "number"}})

  if not vim.wo.diff then
    local tbl = {_fillers = {}, _first_row = s, _offsets = {}}
    return setmetatable(tbl, Fillers)
  end

  local fillers = {}
  for row = s, e, 1 do
    local diff_count = vim.fn.diff_filler(row)
    if diff_count ~= 0 then
      table.insert(fillers, {row = row, diff_count = diff_count})
    end
  end

  local offsets = {}
  local offset = 0
  for _, filler in ipairs(fillers) do
    offset = offset + filler.diff_count
    offsets[filler.row] = offset
  end

  local tbl = {_fillers = fillers, _first_row = s, _offsets = offsets}
  return setmetatable(tbl, Fillers)
end

function Fillers.offset(self, row)
  local nearest_row = 0
  for r in pairs(self._offsets) do
    if nearest_row < r and r <= row then
      nearest_row = r
    end
  end
  return self._offsets[nearest_row] or 0
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
