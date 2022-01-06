local M = {}

function M.set_column(column)
  vim.validate({ column = { column, "number" } })
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_win_set_cursor(0, { row, column - 1 })
end

return M
