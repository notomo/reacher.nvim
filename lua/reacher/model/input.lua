local M = {}

local Inputs = {}
Inputs.__index = Inputs
M.Inputs = Inputs

function Inputs.new(inputs)
  vim.validate({inputs = {inputs, "table"}})
  local head = table.remove(inputs, 1) or ""
  local tbl = {_inputs = inputs, head = head}
  return setmetatable(tbl, Inputs)
end

function Inputs.__eq(a, b)
  return a.head == b.head and vim.deep_equal(a._inputs, b._inputs)
end

function Inputs.parse(line)
  vim.validate({line = {line, "string"}})
  local inputs = vim.tbl_filter(function(input)
    return input ~= ""
  end, vim.split(line:lower(), "%s+"))
  return Inputs.new(inputs)
end

function Inputs.iter(self)
  return next, self._inputs, nil
end

function Inputs.matched(self, line)
  vim.validate({line = {line, "string"}})
  local ranges = {}
  for _, input in self:iter() do
    local s
    local e = 0
    repeat
      s, e = line:find(input, e + 1, true)
      if s ~= nil then
        table.insert(ranges, {s, e})
      end
    until s == nil
  end
  return ranges
end

return M
