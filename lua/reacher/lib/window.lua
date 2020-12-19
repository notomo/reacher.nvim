local M = {}

M.close = function(id)
  vim.validate({id = {id, "number"}})
  if not vim.api.nvim_win_is_valid(id) then
    return
  end
  vim.api.nvim_win_close(id, true)
end

M.enter = function(id)
  vim.validate({id = {id, "number"}})
  if not vim.api.nvim_win_is_valid(id) then
    return
  end
  vim.api.nvim_set_current_win(id)
end

M.jump = function(id, row, column)
  vim.validate({id = {id, "number"}, row = {row, "number"}, column = {column, "number"}})
  M.enter(id)
  vim.api.nvim_command("normal! m'")
  vim.api.nvim_win_set_cursor(id, {row, column})
end

return M
