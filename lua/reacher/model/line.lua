local Position = require("reacher.model.position").Position
local ColumnRange = require("reacher.model.column_range").ColumnRange

local vim = vim

local M = {}

local Line = {}
Line.__index = Line
M.Line = Line

function Line.new(str)
  vim.validate({str = {str, "string"}})
  local tbl = {str = str}
  return setmetatable(tbl, Line)
end

local Lines = {}
M.Lines = Lines

function Lines.new(first_column, last_column, conceals, folds, fillers, wrap)
  local lines = {}

  local strs, column_range = ColumnRange.trim(conceals:lines(), first_column, last_column, wrap)

  for _, str in ipairs(strs) do
    table.insert(lines, Line.new(str))
  end

  lines = fillers:add_to(lines)
  lines = folds:apply_to(lines)

  local tbl = {_lines = lines, _folds = folds, _column_range = column_range}
  return setmetatable(tbl, Lines)
end

function Lines.__index(self, k)
  if type(k) == "number" then
    local line = self._lines[k] or {}
    return line.str
  end
  return Lines[k]
end

function Lines.copy_to(self, bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, vim.tbl_map(function(line)
    return line.str
  end, self._lines))
  self._folds:execute()
end

function Lines.offset(self, first_row)
  return Position.new(first_row - 1, self._column_range.s - 1)
end

function Lines.iter(self)
  return next, self._lines, nil
end

return M
