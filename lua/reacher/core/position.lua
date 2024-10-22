local vim = vim

local Position = {}
Position.__index = Position

--- @param row integer
--- @param column integer
function Position.new(row, column)
  local tbl = { row = row, column = column }
  return setmetatable(tbl, Position)
end

--- @param window_id integer
function Position.cursor(window_id)
  local cursor = vim.api.nvim_win_get_cursor(window_id)
  return Position.new(cursor[1], cursor[2])
end

return Position
