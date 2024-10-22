local M = {}

--- @param is_cancel boolean
--- @param mode string?
function M.restore_visual_mode(is_cancel, mode)
  vim.cmd.normal({ args = { "gv" }, bang = true, mods = { silent = true, emsg_silent = true, noautocmd = true } })
  if mode ~= "i" then
    return
  end
  -- for adjust column
  local row, column = unpack(vim.api.nvim_win_get_cursor(0))
  local last_column = vim.fn.col("$") - 1
  if column == last_column and is_cancel then
    -- HACK: for visual mode
    vim.schedule(function()
      vim.api.nvim_win_set_cursor(0, { row, last_column })
    end)
    return
  end
  vim.api.nvim_win_set_cursor(0, { row, column + 1 })
end

return M
