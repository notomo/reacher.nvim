local vim = vim

local M = {}

M._regex = vim.regex("\\v[[:alnum:]]+")

function M.collect(self, lines)
  local targets = {}
  for row, line in ipairs(lines) do
    targets = vim.list_extend(targets, self:_search(line.str, row))
  end
  return targets
end

function M._search(self, line, row)
  local targets = {}
  local column = 1
  local regex = M._regex
  repeat
    local str = line:sub(column)
    local s, e = regex:match_str(str)
    if s ~= nil then
      table.insert(targets, self.new_target(row, column + s - 1, str:sub(s + 1, e)))
      column = column + e + 1
    end
  until s == nil
  return targets
end

return M
