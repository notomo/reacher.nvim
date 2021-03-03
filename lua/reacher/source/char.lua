local vim = vim

local M = {}

M.matcher_name = "regex"
M.matcher_method_name = "partial"

function M.update(self, ctx)
  local pattern = ctx.input
  if #pattern == 0 then
    return self:_cursor_target(ctx.lines, ctx.cursor)
  end

  local targets = {}
  for row, line in ipairs(ctx.lines) do
    targets = vim.list_extend(targets, self.matcher:match_str_all(line.str, row, 0, pattern))
  end
  return targets
end

function M._cursor_target(self, lines, cursor)
  local row = cursor.row
  local column = cursor.column
  local line = lines[row] or {str = ""}
  local str, s, e = unpack(vim.fn.matchstrpos(line.str, ".", column))
  if s ~= -1 then
    return {self.new_target(row, s, e, str)}
  end
  return {self.new_virtual_target(row, column, column + 1, " ")}
end

return M
