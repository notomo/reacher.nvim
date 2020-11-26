local M = {}

local matched_positions = function(line, pattern, row)
  local positions = {}
  local index = 0
  repeat
    local s, e = line:find(pattern, index)
    if s ~= nil then
      table.insert(positions, {row = row, column = s - 1, line = line:sub(s)})
      index = e + 1
    end
  until s == nil
  return positions
end

M.collect = function(bufnr, first_row, last_row)
  local positions = {}
  local lines = vim.api.nvim_buf_get_lines(bufnr, first_row - 1, last_row, true)
  local row = first_row
  for _, line in ipairs(lines) do
    local matched = matched_positions(line, "%w+", row)
    positions = vim.list_extend(positions, matched)
    row = row + 1
  end
  return positions
end

return M
