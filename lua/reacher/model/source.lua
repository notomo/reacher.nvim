local modulelib = require("reacher.lib.module")
local Target = require("reacher.model.target").Target
local SourceResult = require("reacher.model.source_result").SourceResult
local Translator = require("reacher.model.translator").Translator
local Matcher = require("reacher.model.matcher").Matcher
local regex_matcher = Matcher.must("regex")

local M = {}

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
    regex_matcher = regex_matcher,
    translator = Translator.new(regex_matcher),
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

function Source.to_targets_from_str(self, str, row, start_column, pattern)
  return self.translator:to_targets_from_str(self.matcher, str, row, start_column, pattern)
end

function Source.to_targets_from(self, original_targets, pattern)
  return self.translator:to_targets_from_targets(self.matcher, original_targets, pattern)
end

return M
