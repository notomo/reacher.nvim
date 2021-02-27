local vim = vim

local M = {}

local Input = {}
Input.__index = Input
M.Input = Input

function Input.new(line)
  vim.validate({line = {line, "string"}})

  local ignorecase = false
  local str = line
  if not line:find("[A-Z]") then
    ignorecase = true
    str = line:lower()
  end

  local tbl = {str = str, ignorecase = ignorecase}
  return setmetatable(tbl, Input)
end

function Input.__eq(a, b)
  return a.str == b.str
end

return M
