local M = {}

M.matcher_name = "regex"
M.matcher_method_name = "partial"

function M.collect(self, lines)
  local targets = {}
  for row, line in ipairs(lines) do
    -- TODO ignore fold and diff filler
    table.insert(targets, self.new_target(row, 0, #line.str, line.str))
  end
  if #targets == 0 then
    return nil, "no targets"
  end
  return {targets = targets}
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
