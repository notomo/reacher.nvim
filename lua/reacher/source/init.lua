local modulelib = require("reacher.lib.module")
local Targets = require("reacher.model.target").Targets
local Target = require("reacher.model.target").Target

local M = {}

local SourceResult = {}
SourceResult.__index = SourceResult
M.SourceResult = SourceResult

function SourceResult.new(source, result)
  vim.validate({source = {source, "table"}, result = {result, "table"}})
  local tbl = {_source = source, _result = result, targets = Targets.new(result.targets)}
  return setmetatable(tbl, SourceResult)
end

function SourceResult.filter(self, input, bufnr, cursor)
  local ctx = {input = input, bufnr = bufnr, cursor = cursor}
  return Targets.new(self._source:filter(ctx, self._result))
end

local Source = {}
M.Source = Source

function Source.new(name)
  vim.validate({name = {name, "string"}})

  local source = modulelib.find("reacher.source." .. name)
  if source == nil then
    return nil, "not found source: " .. name
  end

  local tbl = {
    name = name,
    _source = source,
    new_target = Target.new,
    new_virtual_target = Target.new_virtual,
  }
  return setmetatable(tbl, Source), nil
end

function Source.collect(self, lines)
  vim.validate({lines = {lines, "table"}})

  local raw_lines = {}
  for _, line in lines:iter() do
    table.insert(raw_lines, line)
  end

  local result, err = self._source.collect(self, raw_lines)
  if err ~= nil then
    return nil, ("source `%s`: %s"):format(self.name, err)
  end
  if not result.targets then
    return nil, ("source `%s`: `targets` field is required."):format(self.name)
  end
  return SourceResult.new(self, result), nil
end

function Source.__index(self, k)
  return rawget(Source, k) or self._source[k]
end

return M
