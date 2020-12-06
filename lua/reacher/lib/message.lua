local M = {}

M.error = function(err)
  vim.api.nvim_err_write("[reacher] " .. err .. "\n")
end

return M
