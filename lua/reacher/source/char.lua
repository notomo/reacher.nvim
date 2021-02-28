local vim = vim

local M = {}

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
    local ok, result = pcall(vim.fn.matchstrpos, line, pattern, column)
    if not ok then
      break
    end

    local str, s, e = unpack(result)
    if s == e then
      break
    end
    table.insert(targets, self.new_target(row, s, e, str))
    column = e
  until s == -1
  return targets
end

return M
