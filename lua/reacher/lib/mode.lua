local M = {}

local CTRL_V = vim.api.nvim_eval("\"\\<C-v>\"")
local ESC = vim.api.nvim_eval("\"\\<ESC>\"")
function M.leave_visual_mode()
  local mode = vim.api.nvim_get_mode().mode
  if mode == "v" or mode == "V" or mode == CTRL_V then
    vim.cmd("normal! " .. ESC)
    return true, mode
  end
  return false, mode
end

function M.restore_visual_mode(is_cancel, mode)
  vim.validate({is_cancel = {is_cancel, "boolean"}, mode = {mode, "string", true}})
  vim.cmd("silent! noautocmd normal! gv")
  if mode ~= "i" then
    return
  end
  -- for adjust column
  local row, column = unpack(vim.api.nvim_win_get_cursor(0))
  local last_column = vim.fn.col("$") - 1
  if column == last_column and is_cancel then
    -- HACK: for visual mode
    vim.schedule(function()
      vim.api.nvim_win_set_cursor(0, {row, last_column})
    end)
    return
  end
  vim.api.nvim_win_set_cursor(0, {row, column + 1})
end

return M
