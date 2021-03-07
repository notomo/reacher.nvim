local M = {}

M.opts = {matcher_opts = {name = "regex", method_name = "partial"}, input_separator = "\\v\\s+"}

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

return M
