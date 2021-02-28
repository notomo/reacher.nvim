local M = {}

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

-- TODO refactor matcher
function M.filter(_, ctx, result)
  local input = ctx.input
  local targets = vim.tbl_filter(function(target)
    local str, input_str = input:apply_smartcase(target.str)
    return vim.startswith(str, input_str)
  end, result.targets)

  local input_width = #input.str
  if input_width == 0 then
    return targets
  end

  return vim.tbl_map(function(target)
    return target:change_width(input_width)
  end, targets)
end

return M
