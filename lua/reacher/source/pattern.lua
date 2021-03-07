local vim = vim

local M = {}

M.opts = {matcher_opts = {name = "regex", method_name = "partial"}}

function M.update(self, ctx)
  if #ctx.inputs == 1 and ctx.inputs[1] == "" then
    local row = ctx.cursor.row
    local column = ctx.cursor.column
    local line = ctx.lines[row] or {str = ""}
    return self.translator:to_targets_from_position(line.str, row, column)
  end

  local targets = {}
  for row, line in ipairs(ctx.lines) do
    for _, input in ipairs(ctx.inputs) do
      targets = vim.list_extend(targets, self:to_targets_from_str(line.str, row, 0, input))
    end
  end
  return targets
end

return M
