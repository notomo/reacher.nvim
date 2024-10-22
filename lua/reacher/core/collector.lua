local Translator = require("reacher.core.translator")
local regex_matcher = require("reacher.core.matcher").must("regex")
local vim = vim

local Collector = {}
Collector.__index = Collector

--- @param window_id integer
--- @param matcher table
--- @param lines table
--- @param number_sign_width integer
--- @param cursor table?
function Collector.new(window_id, matcher, lines, number_sign_width, cursor)
  local raw_lines = {}
  for _, line in lines:iter() do
    table.insert(raw_lines, line)
  end

  local tbl = {
    _translator = Translator.new(window_id, matcher, regex_matcher, number_sign_width),
    _raw_lines = raw_lines,
    _cursor = cursor,
  }
  return setmetatable(tbl, Collector)
end

function Collector.collect(self, input_line)
  if #input_line == 0 then
    if not self._cursor then
      return {}
    end
    local row = self._cursor.row
    local column = self._cursor.column
    local line = self._raw_lines[row]
    if not line then
      return {}
    end
    return self._translator:to_targets_from_position(line.str, row, column)
  end

  local raw_targets = {}
  for row, line in ipairs(self._raw_lines) do
    raw_targets =
      vim.list_extend(raw_targets, self._translator:to_targets_from_str(line.str, row, line.column_offset, input_line))
  end
  return raw_targets
end

return Collector
