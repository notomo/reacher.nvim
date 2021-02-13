local Target = require("reacher.model.target").Target

local M = {}

local search = function(line, regex, row)
  local targets = {}
  local index = 1
  repeat
    local str = line:sub(index)
    local s, e = regex:match_str(str)
    if s ~= nil then
      table.insert(targets, Target.new(row, index + s - 1, str:sub(s + 1, e)))
      index = index + e + 1
    end
  until s == nil
  return targets
end

M.collect = function(lines)
  local targets = {}
  local regex = vim.regex("\\v[[:alnum:]]+")
  for _, line in lines:iter() do
    local matched = search(line.str, regex, line.row)
    targets = vim.list_extend(targets, matched)
  end
  return targets
end

return M
