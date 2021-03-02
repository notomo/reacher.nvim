local vim = vim

local M = {}

M.matcher_name = "regex"
M.matcher_method_name = "startswith"

function M.collect(self, lines)
  local targets = {}
  for row, line in ipairs(lines) do
    targets = vim.list_extend(targets, self:_search(line.str, row))
  end
  if #targets == 0 then
    return nil, "no targets"
  end
  return {targets = targets}
end

local Matcher = require("reacher.matcher").Matcher
local regex_matcher = Matcher.new("regex")

function M._search(_, line, row)
  local targets = {}
  local column = 0
  repeat
    local target = regex_matcher:partial(line, row, column, {str = "\\v[[:alnum:]]+"})
    if not target then
      break
    end
    table.insert(targets, target)
    column = target.column_end
  until target == nil
  return targets
end

function M.filter(self, ctx, result)
  local targets = {}
  for _, target in ipairs(result.targets) do
    local t = self.matcher:match(target, ctx.input)
    if t then
      table.insert(targets, t)
    end
  end
  return targets
end

return M
