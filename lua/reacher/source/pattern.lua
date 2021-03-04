local vim = vim

local M = {}

M.matcher_name = "regex"
M.matcher_method_name = "partial"

function M.update(self, ctx)
  local pattern = ctx.input
  if #pattern == 0 then
    local row = ctx.cursor.row
    local column = ctx.cursor.column
    local line = ctx.lines[row] or {str = ""}
    return self.translator:to_targets_from_position(line.str, row, column)
  end

  local targets = {}
  for row, line in ipairs(ctx.lines) do
    targets = vim.list_extend(targets, self:to_targets_from_str(line.str, row, 0, pattern))
  end
  return targets
end

return M