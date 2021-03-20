local modelib = require("reacher.lib.mode")

local M = {}

local OldMode = {}
OldMode.__index = OldMode
M.OldMode = OldMode

function OldMode.to_normal_mode()
  local was_visual_mode, mode = modelib.leave_visual_mode()

  local row = vim.fn.line(".")
  local range = {row, row}
  if was_visual_mode then
    local s = vim.api.nvim_buf_get_mark(0, "<")
    local e = vim.api.nvim_buf_get_mark(0, ">")
    range = {s[1], e[1]}
  end

  local tbl = {_mode = mode, _range = range, is_visual = was_visual_mode}
  return setmetatable(tbl, OldMode)
end

function OldMode.is_in(self, mode_chars)
  vim.validate({mode_chars = {mode_chars, "string"}})
  if mode_chars:find("v") and self.is_visual then
    return true
  end
  return mode_chars:find(self._mode)
end

function OldMode.in_range(self, row)
  return self._range[1] <= row and row <= self._range[2]
end

return M
