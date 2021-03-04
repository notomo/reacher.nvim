local Target = require("reacher.model.target").Target

local M = {}

local Translator = {}
Translator.__index = Translator
M.Translator = Translator

function Translator.new(regex_matcher)
  vim.validate({regex_matcher = {regex_matcher, "table"}})
  local tbl = {_regex_matcher = regex_matcher}
  return setmetatable(tbl, Translator)
end

function Translator.to_targets_from_str(_, matcher, str, row, start_column, pattern)
  local targets = {}
  local column_offset = start_column
  repeat
    local matched, s, e = matcher:match(str, pattern, column_offset)
    if not matched then
      break
    end
    local target = Target.new(row, s, e, matched)
    table.insert(targets, target)
    column_offset = target.column_end
  until matched == nil
  return targets
end

function Translator.to_targets_from_targets(_, matcher, original_targets, pattern)
  local targets = {}
  for _, t in ipairs(original_targets) do
    local str = t.str
    local column_offset = 0
    repeat
      local matched, s, e = matcher:match(str, pattern, column_offset)
      if not matched then
        break
      end
      local target = Target.new(t.row, t.column + s, t.column + e, matched)
      table.insert(targets, target)
      column_offset = target.column_end
    until matched == nil
  end
  return targets
end

function Translator.to_targets_from_position(self, str, row, column)
  local matched, s, e = self._regex_matcher:match(str, ".", column)
  if matched then
    return {Target.new(row, s, e, matched)}
  end
  return {Target.new_virtual(row, column, column + 1, " ")}
end

return M
