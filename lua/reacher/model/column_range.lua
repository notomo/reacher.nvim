local vim = vim

local M = {}

local ColumnRange = {}
ColumnRange.__index = ColumnRange
M.ColumnRange = ColumnRange

function ColumnRange.new(str, virtual_s, virtual_e)
  local trimmed = str
  local _, s, e = unpack(vim.fn.matchstrpos(str, "\\%>" .. virtual_s .. "v.*\\%<" .. virtual_e .. "v"))
  if s == e then
    return ColumnRange.new_default("")
  end
  trimmed = str:sub(1, e)

  local tbl = {str = trimmed, s = s}
  return setmetatable(tbl, ColumnRange)
end

function ColumnRange.new_default(str)
  local tbl = {str = str, s = 0}
  return setmetatable(tbl, ColumnRange)
end

local ColumnRanges = {}
ColumnRanges.__index = ColumnRanges
M.ColumnRanges = ColumnRanges

function ColumnRanges.new(line_strs, virtual_s, virtual_e, wrap)
  vim.validate({
    line_strs = {line_strs, "table"},
    virtual_s = {virtual_s, "number"},
    virtual_e = {virtual_e, "number"},
    wrap = {wrap, "boolean"},
  })

  local tbl = {_column_ranges = {}}
  local self = setmetatable(tbl, ColumnRanges)

  local strs = vim.deepcopy(line_strs)
  if wrap then
    self._column_ranges = vim.tbl_map(function(str)
      return ColumnRange.new_default(str)
    end, strs)
    local last_line = M.calc_displayed_last_line()
    if last_line then
      table.insert(self._column_ranges, ColumnRange.new_default(last_line))
    end
    return self
  end

  local vs = virtual_s - 1
  local ve = virtual_e + 2
  for _, str in ipairs(strs) do
    table.insert(self._column_ranges, ColumnRange.new(str, vs, ve))
  end
  return self
end

function ColumnRanges.iter(self)
  return ipairs(self._column_ranges)
end

-- HACK: for wrapped last line lying on the window bottom
function M.calc_displayed_last_line()
  local height = vim.api.nvim_win_get_height(0)
  local count = vim.fn.line("$")
  if height > count then
    return nil
  end

  local saved = vim.fn.winsaveview()
  local scrolloff = vim.api.nvim_exec("silent! echo &scrolloff", true)
  vim.cmd("silent! noautocmd setlocal scrolloff=0")
  local reset = function()
    vim.cmd("silent! noautocmd setlocal scrolloff=" .. tostring(scrolloff))
    vim.fn.winrestview(saved)
  end

  local last_row = vim.fn.line("w$")
  vim.cmd(("silent! noautocmd %d"):format(last_row))
  local rest_height = height - vim.fn.winline()

  vim.cmd("silent! noautocmd normal! j")
  vim.cmd("silent! noautocmd normal! g0")

  if height - vim.fn.winline() <= 0 then
    return reset()
  end
  local row = vim.fn.line(".")
  local column = vim.fn.col(".")
  local line = vim.fn.getline(row)
  local line_length = #line
  local is_wrapped = false
  while true do
    vim.cmd("silent! noautocmd normal! gj")
    local r = vim.fn.line(".")
    local c = vim.fn.col(".")
    if r ~= row or (row == r and column == c) then
      break
    end
    is_wrapped = true

    if vim.fn.col("$") == line_length then
      return reset()
    end

    column = c
    rest_height = rest_height - 1
    if rest_height <= 0 then
      break
    end
  end

  if not is_wrapped then
    return reset()
  end

  reset()
  return line:sub(1, column - 1)
end

return M
