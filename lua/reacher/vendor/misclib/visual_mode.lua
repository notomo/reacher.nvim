local api = vim.api

local M = {}

function M.row_range()
  if not M.leave() then
    return nil
  end
  return {
    first = api.nvim_buf_get_mark(0, "<")[1],
    last = api.nvim_buf_get_mark(0, ">")[1],
  }
end

local CTRL_V = api.nvim_replace_termcodes("<C-v>", true, false, true)
local is_current = function()
  local mode = api.nvim_get_mode().mode
  return mode == "v" or mode == "V" or mode == CTRL_V, mode
end

local ESC = api.nvim_replace_termcodes("<ESC>", true, false, true)
function M.leave()
  local ok, mode = is_current()
  if not ok then
    return false, mode
  end
  vim.cmd.normal({ args = { ESC }, bang = true })
  return true, mode
end

function M.is_current()
  local ok = is_current()
  return ok
end

return M
