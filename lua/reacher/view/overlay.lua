local windowlib = require("reacher.lib.window")
local highlightlib = require("reacher.lib.highlight")
local HlFactory = require("reacher.lib.highlight").HlFactory
local Collector = require("reacher.core.collector").Collector
local Position = require("reacher.core.position").Position
local Targets = require("reacher.core.target").Targets
local vim = vim

local M = {}

local Overlay = {}
Overlay.__index = Overlay
M.Overlay = Overlay

function Overlay.open(matcher, origin, for_current_window)
  vim.validate({
    matcher = {matcher, "table"},
    origin = {origin, "table"},
    for_current_window = {for_current_window, "boolean"},
  })

  local bufnr = vim.api.nvim_create_buf(false, true)
  local window_id = origin:copy_to_floating_win(bufnr)

  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].modifiable = false

  local hl_bg_name = "ReacherBackgroundNormal"
  if origin:is_floating() then
    hl_bg_name = "ReacherBackgroundNormalFloat"
  end
  vim.wo[window_id].winhighlight = ("Normal:%s,Search:None"):format(hl_bg_name)

  local cursor
  if for_current_window then
    cursor = origin.cursor
  end

  local tbl = {
    _window_id = window_id,
    _origin = origin,
    _match_highlight = HlFactory.new("reacher", bufnr),
    _cursor_highlight = HlFactory.new("reacher_cursor", bufnr),
    _collector = Collector.new(origin.window_id, matcher, origin.lines, cursor),
  }
  return setmetatable(tbl, Overlay), nil
end

function Overlay.collect_targets(self, input_line)
  return self._collector:collect(input_line)
end

function Overlay.enter_origin(self)
  self._origin:enter()
end

function Overlay.jump(self, target, mode)
  return self._origin:jump(target.row, target.column, mode)
end

function Overlay.close(self)
  windowlib.close(self._window_id)
end

function Overlay.highlight_match(self, target)
  local highlighter = self._match_highlight:create()
  target:highlight(highlighter, "ReacherMatch")
end

function Overlay.highlight_cursor(self, target)
  local highlighter = self._cursor_highlight:create()
  target:highlight(highlighter, "ReacherCurrentMatch")
end

function Overlay.reset_match_highlight(self)
  self._match_highlight:reset()
end

function Overlay.reset_cursor_highlight(self)
  self._cursor_highlight:reset()
end

Overlay.hl_group_script = table.concat({
  highlightlib.link("ReacherMatch", "Directory"),
  highlightlib.link("ReacherCurrentMatchInsert", "IncSearch"),
  highlightlib.link("ReacherCurrentMatchNormal", "Search"),
}, "\n")

local Overlays = {}
Overlays.__index = Overlays
M.Overlays = Overlays

function Overlays.open(matcher, current_origin, other_origins)
  highlightlib.link("ReacherCurrentMatch", "ReacherCurrentMatchInsert", true)
  highlightlib.define_from_src("ReacherBackgroundNormal", "Normal", {
    fg_hl_group = "Comment",
    fg_default = "#8d9eb2",
    bg_default = "#334152",
  })
  highlightlib.define_from_src("ReacherBackgroundNormalFloat", "NormalFloat", {
    fg_hl_group = "Comment",
    fg_default = "#8d9eb2",
    bg_default = "#334152",
  })

  local current_overlay = Overlay.open(matcher, current_origin, true)
  local overlays = {[current_origin.window_id] = current_overlay}
  for _, origin in ipairs(other_origins) do
    overlays[origin.window_id] = Overlay.open(matcher, origin, false)
  end

  local win_pos = vim.api.nvim_win_get_position(current_origin.window_id)
  local tbl = {
    _current_overlay = current_overlay,
    _overlays = overlays,
    _targets = Targets.new({}),
    _cursor = Position.new(current_origin.cursor.row + win_pos[1] - 1, current_origin.cursor.column + win_pos[2]),
  }
  return setmetatable(tbl, Overlays)
end

function Overlays.move_cursor(self, action_name)
  local targets = self._targets[action_name](self._targets)
  self:_update_cursor(targets)
end

function Overlays.close(self)
  self._current_overlay:enter_origin()
  for _, overlay in pairs(self._overlays) do
    overlay:close()
  end
end

function Overlays.finish(self)
  local target = self._targets:current()
  if not target then
    return
  end

  local mode = vim.api.nvim_get_mode().mode
  return function()
    return self._overlays[target.window_id]:jump(target, mode)
  end
end

function Overlays.update(self, input_line)
  local raw_targets = {}
  for _, overlay in pairs(self._overlays) do
    raw_targets = vim.list_extend(raw_targets, overlay:collect_targets(input_line))
  end
  local targets = Targets.new(raw_targets)

  self:_reset_match_highlight()
  for _, target in targets:iter() do
    self._overlays[target.window_id]:highlight_match(target)
  end

  self:_update_cursor(targets:match(self._cursor))
end

function Overlays._update_cursor(self, targets)
  self:_reset_cursor_highlight()
  self._targets = targets

  local target = targets:current()
  if target then
    self._overlays[target.window_id]:highlight_cursor(target)
  end
end

function Overlays._reset_match_highlight(self)
  for _, overlay in pairs(self._overlays) do
    overlay:reset_match_highlight()
  end
end

function Overlays._reset_cursor_highlight(self)
  for _, overlay in pairs(self._overlays) do
    overlay:reset_cursor_highlight()
  end
end

return M
