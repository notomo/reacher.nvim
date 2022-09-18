local vim = vim

local OldMode = {}
OldMode.__index = OldMode

function OldMode.new(mode, range, was_visual_mode)
  vim.validate({
    mode = { mode, "string" },
    range = { range, "table", true },
    was_visual_mode = { was_visual_mode, "boolean", true },
  })

  range = range or { vim.fn.line("."), vim.fn.line(".") }
  was_visual_mode = was_visual_mode or false

  local tbl = { _mode = mode, _range = range, is_visual = was_visual_mode }
  return setmetatable(tbl, OldMode)
end

function OldMode.to_normal_mode()
  local was_visual_mode, mode = require("reacher.vendor.misclib.visual_mode").leave()

  local range
  if was_visual_mode then
    local s = vim.api.nvim_buf_get_mark(0, "<")
    local e = vim.api.nvim_buf_get_mark(0, ">")
    range = { s[1], e[1] }
  end
  return OldMode.new(mode, range, was_visual_mode)
end

function OldMode.normal()
  return OldMode.new("n")
end

function OldMode.is_in(self, mode_chars)
  vim.validate({ mode_chars = { mode_chars, "string" } })
  if mode_chars:find("v") and self.is_visual then
    return true
  end
  return mode_chars:find(self._mode)
end

function OldMode.in_range(self, row)
  return self._range[1] <= row and row <= self._range[2]
end

return OldMode
