local M = {}

local Position = {}
Position.__index = Position
M.Position = Position

function Position.new(row, column)
  local tbl = {row = row, column = column}
  return setmetatable(tbl, Position)
end

function Position.cursor(window_id)
  vim.validate({window_id = {window_id, "number"}})
  local cursor = vim.api.nvim_win_get_cursor(window_id)
  return Position.new(cursor[1], cursor[2])
end

return M
