local modulelib = require("reacher.lib.module")
local Targets = require("reacher.model.target").Targets
local Target = require("reacher.model.target").Target
local Matcher = require("reacher.matcher").Matcher

local M = {}

local SourceResult = {}
SourceResult.__index = SourceResult
M.SourceResult = SourceResult

function SourceResult.new(source, collected, raw_lines)
  vim.validate({
    source = {source, "table"},
    collected = {collected, "table"},
    raw_lines = {raw_lines, "table"},
  })
  local tbl = {
    matcher = source.matcher,
    targets = Targets.new(collected.targets),
    _source = source,
    _collected = collected,
    _raw_lines = raw_lines,
  }
  return setmetatable(tbl, SourceResult)
end

function SourceResult.update(self, input, bufnr, cursor)
  local ctx = {input = input, bufnr = bufnr, cursor = cursor, lines = self._raw_lines}
  local update
  if self._source.update ~= nil then
    update = self._source.update
  else
    update = self._default_update
  end
  local raw_targets = update(self, ctx, self._collected)
  return Targets.new(raw_targets)
end

function SourceResult._default_update(self, ctx, collected)
  return self.matcher:match_all(collected.targets, ctx.input)
end

function SourceResult.__index(self, k)
  return rawget(SourceResult, k) or self._source[k]
end

local Source = {}
M.Source = Source

function Source.new(name)
  vim.validate({name = {name, "string"}})

  local source = modulelib.find("reacher.source." .. name)
  if source == nil then
    return nil, "not found source: " .. name
  end

  local matcher, err = Matcher.new(source.matcher_name, source.matcher_method_name)
  if err ~= nil then
    return nil, err
  end

  local tbl = {
    name = name,
    matcher = matcher,
    new_target = Target.new,
    new_virtual_target = Target.new_virtual,
    new_matcher = Matcher.new,
    _source = source,
  }
  return setmetatable(tbl, Source), nil
end

function Source.collect(self, lines)
  vim.validate({lines = {lines, "table"}})

  local raw_lines = {}
  for _, line in lines:iter() do
    table.insert(raw_lines, line)
  end

  local collect
  if self._source.collect ~= nil then
    collect = self._source.collect
  else
    collect = self._default_collect
  end
  local collected, err = collect(self, raw_lines)
  if err ~= nil then
    return nil, ("source `%s`: %s"):format(self.name, err)
  end
  if not collected.targets then
    return nil, ("source `%s`: `targets` field is required."):format(self.name)
  end
  return SourceResult.new(self, collected, raw_lines), nil
end

function Source._default_collect(_, _)
  return {targets = {}}
end

function Source.__index(self, k)
  return rawget(Source, k) or self._source[k]
end

return M
