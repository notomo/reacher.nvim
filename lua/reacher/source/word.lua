local M = {}

local matched_positions = function(line, regex, row)
  local positions = {}
  local index = 1
  repeat
    local str = line:sub(index)
    local s, e = regex:match_str(str)
    if s ~= nil then
      table.insert(positions, {row = row, column = index + s - 1, line = str:sub(s + 1, e)})
      index = index + e + 1
    end
  until s == nil
  return positions
end

M.collect = function(lines)
  local positions = {}
  local regex = vim.regex("\\v[[:alnum:]]+")
  for i, line in ipairs(lines) do
    local matched = matched_positions(line, regex, i, 0)
    positions = vim.list_extend(positions, matched)
  end
  return positions
end

return M
