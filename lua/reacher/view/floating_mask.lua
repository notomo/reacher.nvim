local windowlib = require("reacher.lib.window")

local M = {}

local FloatingMasks = {}
FloatingMasks.__index = FloatingMasks
M.FloatingMasks = FloatingMasks

local FloatingMask = {}
FloatingMask.__index = FloatingMask

function FloatingMasks.new()
  local masks = {}
  for _, window_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local mask, ok = FloatingMask.new(window_id)
    if ok then
      table.insert(masks, mask)
    end
  end

  local tbl = {_masks = masks}
  return setmetatable(tbl, FloatingMasks)
end

function FloatingMasks.filter(self, raw_targets)
  local targets = raw_targets
  for _, mask in ipairs(self._masks) do
    targets = mask:filter(targets)
  end
  return targets
end

function FloatingMask.new(window_id)
  if not windowlib.is_floating(window_id) then
    return nil, false
  end

  local position = vim.api.nvim_win_get_position(window_id)
  local config = vim.api.nvim_win_get_config(window_id)
  local row_offset, col_offset = windowlib.both_sides_border_offsets(config)

  local start_row = position[1]
  local end_row = position[1] + config.height - 1 + row_offset
  local start_col = position[2]
  local end_col = position[2] + config.width - 1 + col_offset
  local tbl = {
    _window_id = window_id,
    _start_row = start_row,
    _end_row = end_row,
    _start_col = start_col,
    _end_col = end_col,
    _zindex = config.zindex,
  }
  return setmetatable(tbl, FloatingMask), true
end

function FloatingMask.filter(self, raw_targets)
  local targets = {}
  for _, target in ipairs(raw_targets) do
    if target.window_id == self._window_id then
      goto ok
    end
    if target.zindex > self._zindex then
      goto ok
    end
    if target.zindex == self._zindex and target.window_id > self._window_id then
      goto ok
    end
    if self._start_row <= target.display_row and target.display_row <= self._end_row and self._start_col <= target.display_column and target.display_column <= self._end_col then
      goto continue
    end

    ::ok::
    table.insert(targets, target)

    ::continue::
  end
  return targets
end

return M
