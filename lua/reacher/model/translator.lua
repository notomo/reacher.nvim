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

function Translator.to_targets_from_targets(_, matcher, targets, pattern)
  local result_targets = {}
  for _, target in ipairs(targets) do
    local matches = {}
    local column_offset = 0
    repeat
      local matched, s, e = matcher:match(target.str, pattern, column_offset)
      if not matched then
        break
      end
      table.insert(matches, {s, e})
      column_offset = target.column + e
    until matched == nil
    if matches[1] then
      table.insert(result_targets, target:with(matches))
    end
  end
  return result_targets
end

function Translator.to_targets_from_position(self, str, row, column)
  local matched, s, e = self._regex_matcher:match(str, ".", column)
  if matched then
    return {Target.new(row, s, e, matched)}
  end
  return {Target.new_virtual(row, column, " ")}
end

return M
