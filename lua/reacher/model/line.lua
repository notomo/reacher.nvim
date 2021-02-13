local M = {}

local Line = {}
Line.__index = Line
M.Line = Line

function Line.new()
  local tbl = {}
  return setmetatable(tbl, Line)
end

local Lines = {}
M.Lines = Lines

function Lines.new(bufnr, first_row, last_row, first_column, last_column, folds, fillers, wrap)
  local strs = vim.api.nvim_buf_get_lines(bufnr, first_row - 1, last_row, true)
  for _, row in folds:rows() do
    strs[row] = ""
  end

  if not wrap then
    strs = vim.tbl_map(function(line)
      return line:sub(first_column, last_column)
    end, strs)
  end

  local lines = {}
  for i, str in ipairs(strs) do
    table.insert(lines, {str = str, row = i + first_row - 1})
  end

  for _, filler in fillers:reverse() do
    for _ = 1, filler.diff_count, 1 do
      local i = filler.row - first_row + 1
      table.insert(lines, i, {str = "", row = i})
    end
  end

  local tbl = {
    _lines = lines,
    _folds = folds,
    strs = vim.tbl_map(function(line)
      return line.str:lower()
    end, lines),
  }
  return setmetatable(tbl, Lines)
end

function Lines.__index(self, k)
  if type(k) == "number" then
    local line = self._lines[k]
    if not line then
      return nil
    end
    return line.str
  end
  return Lines[k]
end

function Lines.copy_to(self, bufnr)
  local strs = vim.tbl_map(function(line)
    return line.str
  end, self._lines)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, strs)

  self._folds:execute()
end

function Lines.iter(self)
  return next, self._lines, nil
end

return M
