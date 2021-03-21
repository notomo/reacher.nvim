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

return M
