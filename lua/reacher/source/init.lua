local modulelib = require("reacher.lib.module")
local Targets = require("reacher.model.target").Targets
local Target = require("reacher.model.target").Target

local M = {}

local Source = {}
M.Source = Source

function Source.new(name)
  vim.validate({name = {name, "string"}})

  local source = modulelib.find("reacher.source." .. name)
  if source == nil then
    return nil, "not found source: " .. name
  end

  local tbl = {name = name, _source = source, new_target = Target.new}
  return setmetatable(tbl, Source), nil
end

function Source.collect(self, lines)
  vim.validate({lines = {lines, "table"}})

  local raw_lines = {}
  for _, line in lines:iter() do
    table.insert(raw_lines, line)
  end

  local raw_targets = self._source.collect(self, raw_lines)
  if #raw_targets == 0 then
    return nil, "no targets: " .. self.name
  end
  return Targets.new(raw_targets), nil
end

function Source.__index(self, k)
  return rawget(Source, k) or self._source[k]
end

return M
