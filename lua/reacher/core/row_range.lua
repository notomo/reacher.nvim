local RowRange = {}
RowRange.__index = RowRange

--- @param window_id integer
--- @param first_row integer?
--- @param last_row integer?
function RowRange.new(window_id, first_row, last_row)
  local tbl = {
    _window_id = window_id,
    _first = first_row,
    _last = last_row,
    given_range = (first_row or last_row) ~= nil,
  }
  return setmetatable(tbl, RowRange)
end

function RowRange.first(self)
  local first_row = vim.api.nvim_win_call(self._window_id, function()
    return vim.fn.line("w0")
  end)
  if not self._first then
    return first_row
  end
  if self._first < first_row then
    return first_row
  end
  return self._first
end

function RowRange.last(self)
  local last_row = vim.api.nvim_win_call(self._window_id, function()
    return vim.fn.line("w$")
  end)
  if not self._last then
    return last_row
  end
  if last_row < self._last then
    return last_row
  end
  return self._last
end

return RowRange
