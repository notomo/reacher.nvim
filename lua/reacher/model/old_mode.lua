local modelib = require("reacher.lib.mode")

local M = {}

local OldMode = {}
OldMode.__index = OldMode
M.OldMode = OldMode

function OldMode.to_normal_mode()
  local was_visual_mode, mode = modelib.leave_visual_mode()
  local tbl = {_mode = mode, is_visual = was_visual_mode}
  return setmetatable(tbl, OldMode)
end

return M
