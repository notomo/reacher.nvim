local M = {}

local RowRange = {}
RowRange.__index = RowRange
M.RowRange = RowRange

function RowRange.new(first_row, last_row)
  vim.validate({first_row = {first_row, "number", true}, last_row = {last_row, "number", true}})
  local tbl = {_first = first_row, _last = last_row, given_range = (first_row or last_row) ~= nil}
  return setmetatable(tbl, RowRange)
end

function RowRange.first(self)
  local first_row = vim.fn.line("w0")
  if not self._first then
    return first_row
  end
  if self._first < first_row then
    return first_row
  end
  return self._first
end

function RowRange.last(self)
  local last_row = vim.fn.line("w$")
  if not self._last then
    return last_row
  end
  if last_row < self._last then
    return last_row
  end
  return self._last
end

return M
