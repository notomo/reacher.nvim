local vim = vim

local M = {}

local Input = {}
Input.__index = Input
M.Input = Input

function Input.new(line)
  vim.validate({line = {line, "string"}})

  local ignorecase = false
  local ignorecase_str = line
  if not line:find("[A-Z]") then
    ignorecase = true
    ignorecase_str = line:lower()
  end

  local tbl = {str = line, _ignorecase = ignorecase, _ignorecase_str = ignorecase_str}
  return setmetatable(tbl, Input)
end

function Input.apply_smartcase(self, str)
  if self._ignorecase then
    return str:lower(), self._ignorecase_str
  end
  return str, self.str
end

function Input.__eq(a, b)
  return a.str == b.str
end

return M
