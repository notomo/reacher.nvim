local M = {}

local matched_positions = function(line, pattern, row)
  local positions = {}
  local index = 1
  local regex = vim.regex(pattern)
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

M.collect = function(bufnr, first_row, last_row)
  local positions = {}
  local lines = vim.api.nvim_buf_get_lines(bufnr, first_row - 1, last_row, true)
  local row = first_row
  for _, line in ipairs(lines) do
    local matched = matched_positions(line, "\\v\\k+", row)
    positions = vim.list_extend(positions, matched)
    row = row + 1
  end
  return positions
end

return M
