local M = {}

function M.close(id)
  vim.validate({id = {id, "number"}})
  if not vim.api.nvim_win_is_valid(id) then
    return
  end
  vim.api.nvim_win_close(id, true)
end

function M.enter(id)
  vim.validate({id = {id, "number"}})
  if not vim.api.nvim_win_is_valid(id) then
    return
  end
  vim.api.nvim_set_current_win(id)
end

function M.jump(id, row, column)
  vim.validate({id = {id, "number"}, row = {row, "number"}, column = {column, "number"}})
  M.enter(id)
  vim.cmd("normal! m'")
  vim.api.nvim_win_set_cursor(id, {row, column})
end

function M.is_floating(id)
  vim.validate({id = {id, "number"}})
  return vim.api.nvim_win_get_config(id).relative ~= ""
end

return M
