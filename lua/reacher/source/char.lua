local vim = vim

local M = {}

M.matcher_name = "regex"
M.matcher_method_name = "partial"

function M.collect(_, lines)
  return {targets = {}, _lines = lines}
end

function M.filter(self, ctx, result)
  local pattern = ctx.input.str
  if #pattern == 0 then
    return self:_cursor_target(result._lines, ctx.cursor)
  end

  local targets = {}
  for row, line in ipairs(result._lines) do
    targets = vim.list_extend(targets, self:_search(pattern, line.str, row))
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

function M._search(self, pattern, line, row)
  local targets = {}
  local column = 0
  repeat
    local target = self.matcher:match_str(line, row, column, {str = pattern})
    if not target then
      break
    end
    table.insert(targets, target)
    column = target.column_end
  until target == nil
  return targets
end

return M
