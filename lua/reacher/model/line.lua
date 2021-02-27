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

  local strs = conceals:lines()
  for _, str in ipairs(strs) do
    table.insert(lines, Line.new(str))
  end

  lines = fillers:add_to(lines)
  lines = folds:apply_to(lines)

  if not wrap then
    lines = vim.tbl_map(function(line)
      line.str = line.str:sub(first_column, last_column)
      return line
    end, lines)
  end

  local tbl = {_lines = lines, _folds = folds}
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

function Lines.iter(self)
  return next, self._lines, nil
end

return M
