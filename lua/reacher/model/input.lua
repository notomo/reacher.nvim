local vim = vim

local M = {}

local Inputs = {}
Inputs.__index = Inputs
M.Inputs = Inputs

function Inputs.new(inputs, ignorecase)
  vim.validate({inputs = {inputs, "table"}, ignorecase = {ignorecase, "boolean"}})
  local head = table.remove(inputs, 1) or ""
  local tbl = {_inputs = inputs, head = head, ignorecase = ignorecase}
  return setmetatable(tbl, Inputs)
end

function Inputs.__eq(a, b)
  return a.head == b.head and vim.deep_equal(a._inputs, b._inputs)
end

function Inputs.parse(line)
  vim.validate({line = {line, "string"}})

  local ignorecase = false
  local str = line
  if not line:find("[A-Z]") then
    ignorecase = true
    str = line:lower()
  end

  local inputs = vim.tbl_filter(function(input)
    return input ~= ""
  end, vim.split(str, "%s+"))
  return Inputs.new(inputs, ignorecase)
end

return M
