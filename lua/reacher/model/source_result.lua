local Targets = require("reacher.model.target").Targets
local vim = vim

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
    targets = Targets.new(collected.targets),
    _source = source,
    _collected = collected,
    _raw_lines = raw_lines,
  }
  return setmetatable(tbl, SourceResult)
end

function SourceResult.update(self, input_line, bufnr, cursor)
  local inputs
  if self.opts.input_separator ~= nil then
    inputs = vim.fn.split(input_line, self.opts.input_separator, false)
  else
    inputs = {input_line}
  end
  if #inputs == 0 then
    inputs = {""}
  end

  local ctx = {inputs = inputs, bufnr = bufnr, cursor = cursor, lines = self._raw_lines}
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
  return self.translator:to_targets_from_targets(self.matcher, collected.targets, ctx.inputs)
end

function SourceResult.__index(self, k)
  return rawget(SourceResult, k) or self._source[k]
end

return M
