local vim = vim

local M = {}

M.pattern = "\\v[[:alnum:]]+"

function M.collect(self, lines)
  local targets = {}
  for row, line in ipairs(lines) do
    targets = vim.list_extend(targets, self.translator:to_targets_from_str(self.regex_matcher, line.str, row, 0, M.pattern))
  end

  if #targets == 0 then
    return nil, "no targets"
  end

  return {targets = targets}
end

M.matcher_name = "regex"
M.matcher_method_name = "startswith"

return M
