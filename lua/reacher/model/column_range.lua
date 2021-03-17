local M = {}

local ColumnRange = {}
ColumnRange.__index = ColumnRange
M.ColumnRange = ColumnRange

function ColumnRange.new(str, virtual_s, virtual_e)
  local trimmed = str
  local matched, s, e = unpack(vim.fn.matchstrpos(str, "\\%>" .. virtual_s .. "v.*\\%<" .. virtual_e .. "v"))
  if s == e then
    return nil
  end
  trimmed = matched

  local s_matched = unpack(vim.fn.matchstrpos(str, "\\%" .. virtual_s + 1 .. "v."))
  if s_matched == "" then
    trimmed = " " .. matched
    s = s - 1
  end

  local tbl = {str = trimmed, s = s, e = e}
  return setmetatable(tbl, ColumnRange)
end

local ColumnRanges = {}
M.ColumnRanges = ColumnRanges

function ColumnRanges.new(strs, virtual_s, virtual_e, wrap)
  vim.validate({
    strs = {strs, "table"},
    virtual_s = {virtual_s, "number"},
    virtual_e = {virtual_e, "number"},
    wrap = {wrap, "boolean"},
  })

  local tbl = {_column_ranges = {}, strs = vim.deepcopy(strs)}
  local self = setmetatable(tbl, ColumnRanges)

  if wrap then
    return self
  end

  local vs = virtual_s - 1
  local ve = virtual_e + 2
  for row, str in ipairs(strs) do
    local column_range = ColumnRange.new(str, vs, ve)
    if column_range then
      self._column_ranges[row] = ColumnRange.new(str, vs, ve)
      self.strs[row] = column_range.str
    else
      self.strs[row] = ""
    end
  end
  return self
end

function ColumnRanges.__index(self, k)
  if type(k) == "number" then
    return self._column_ranges[k]
  end
  return ColumnRanges[k]
end

return M
