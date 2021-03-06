local vim = vim

local M = {}

M.opts = {pattern = "\\v[[:alnum:]]+", matcher_opts = {name = "regex", method_name = "startswith"}}

function M.collect(self, lines)
  local targets = {}
  for row, line in ipairs(lines) do
    targets = vim.list_extend(targets, self.translator:to_targets_from_str(self.regex_matcher, line.str, row, 0, self.opts.pattern))
  end

  if #targets == 0 then
    return nil, "no targets"
  end

  return {targets = targets}
end

return M
