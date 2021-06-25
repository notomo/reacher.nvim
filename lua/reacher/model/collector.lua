local Targets = require("reacher.model.target").Targets
local Translator = require("reacher.model.translator").Translator
local regex_matcher = require("reacher.model.matcher").Matcher.must("regex")
local vim = vim

local M = {}

local Collector = {}
Collector.__index = Collector
M.Collector = Collector

function Collector.new(window_id, matcher, lines, cursor)
  vim.validate({
    window_id = {window_id, "number"},
    matcher = {matcher, "table"},
    lines = {lines, "table"},
    cursor = {cursor, "table"},
  })

  local raw_lines = {}
  for _, line in lines:iter() do
    table.insert(raw_lines, line)
  end

  local tbl = {
    _translator = Translator.new(window_id, matcher, regex_matcher),
    _raw_lines = raw_lines,
    _cursor = cursor,
  }
  local initial_targets = Targets.new({})
  return setmetatable(tbl, Collector), initial_targets
end

function Collector.collect(self, input_line)
  local raw_targets = self:_collect(input_line)
  return Targets.new(raw_targets)
end

function Collector._collect(self, input_line)
  if #input_line == 0 then
    local row = self._cursor.row
    local column = self._cursor.column
    local line = self._raw_lines[row]
    if not line then
      return {}
    end
    return self._translator:to_targets_from_position(line.str, row, column)
  end

  local targets = {}
  for row, line in ipairs(self._raw_lines) do
    targets = vim.list_extend(targets, self._translator:to_targets_from_str(line.str, row, line.column_offset, input_line))
  end
  return targets
end

return M
