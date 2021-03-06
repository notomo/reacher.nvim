local M = {}

local ColumnRange = {}
ColumnRange.__index = ColumnRange
M.ColumnRange = ColumnRange

function ColumnRange.trim(strs, virtual_s, virtual_e, wrap)
  vim.validate({
    strs = {strs, "table"},
    virtual_s = {virtual_s, "number"},
    virtual_e = {virtual_e, "number"},
    wrap = {wrap, "boolean"},
  })

  local tbl = {s = virtual_s, e = virtual_e}
  local self = setmetatable(tbl, ColumnRange)
  if wrap then
    return strs, self
  end

  local result_strs = {}
  local vs = virtual_s - 1
  local ve = virtual_e + 2
  for _, str in ipairs(strs) do
    table.insert(result_strs, self:_trim(str, vs, ve))
  end

  return result_strs, self
end

function ColumnRange._trim(self, str, virtual_s, virtual_e)
  local trimmed = str
  local matched, s, e = unpack(vim.fn.matchstrpos(str, "\\%>" .. virtual_s .. "v.*\\%<" .. virtual_e .. "v"))
  if s == e then
    return ""
  end
  trimmed = matched

  if self.s < s then
    self.s = s
  end

  if self.e < e then
    self.e = e
  end

  local s_matched = unpack(vim.fn.matchstrpos(str, "\\%" .. virtual_s + 1 .. "v."))
  if s_matched == "" then
    trimmed = " " .. matched
  end
  -- TODO: for extends

  return trimmed
end

return M
