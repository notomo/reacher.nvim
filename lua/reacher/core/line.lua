local ColumnRanges = require("reacher.core.column_range").ColumnRanges

local vim = vim

local M = {}

local Line = {}
Line.__index = Line
M.Line = Line

--- @param str string
--- @param column_offset integer
function Line.new(str, column_offset)
  local tbl = { str = str, column_offset = column_offset }
  return setmetatable(tbl, Line)
end

local Lines = {}
M.Lines = Lines

function Lines.new(window_id, first_column, last_column, conceals, folds, fillers, virt_lines, wrap)
  local lines = {}

  local column_ranges = ColumnRanges.new(window_id, conceals:lines(), first_column, last_column, wrap)
  for _, range in column_ranges:iter() do
    table.insert(lines, Line.new(range.str, range.s))
  end
  lines = fillers:add_to(lines)
  lines = folds:apply_to(lines)

  local tbl = {
    _lines = lines,
    _folds = folds,
    _first_column = first_column,
    _virt_lines = virt_lines,
  }
  return setmetatable(tbl, Lines)
end

function Lines.__index(self, k)
  if type(k) == "number" then
    local line = self._lines[k] or {}
    return line.str
  end
  return Lines[k]
end

function Lines.copy_to(self, bufnr, window_id)
  vim.api.nvim_buf_set_lines(
    bufnr,
    0,
    -1,
    true,
    vim
      .iter(self._lines)
      :map(function(line)
        return line.str
      end)
      :totable()
  )
  self._virt_lines:set(bufnr)
  self._folds:execute(window_id)
  vim.api.nvim_win_call(window_id, function()
    vim.fn.winrestview({ leftcol = self._first_column - 1 })
  end)
end

function Lines.iter(self)
  return ipairs(self._lines)
end

return M
