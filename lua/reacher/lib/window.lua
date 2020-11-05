local M = {}

M.close = function(id)
  if not vim.api.nvim_win_is_valid(id) then
    return
  end
  vim.api.nvim_win_close(id, true)
end

M.enter = function(id)
  if not vim.api.nvim_win_is_valid(id) then
    return
  end
  vim.api.nvim_set_current_win(id)
end

return M
