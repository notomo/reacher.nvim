local windowlib = require("reacher.lib.window")
local highlightlib = require("reacher.lib.highlight")
local HlFactory = require("reacher.lib.highlight").HlFactory
local Collector = require("reacher.model.collector").Collector
local vim = vim

local M = {}

local Overlay = {}
Overlay.__index = Overlay
M.Overlay = Overlay

function Overlay.open(matcher, origin)
  local bufnr = vim.api.nvim_create_buf(false, true)
  local window_id = origin:copy_to_floating_win(bufnr)

  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].modifiable = false
  vim.wo[window_id].winhighlight = "Normal:ReacherBackground"

  highlightlib.link("ReacherCurrentMatch", "ReacherCurrentMatchInsert", true)
  highlightlib.set_background("ReacherBackground", origin.window_id, {
    fg_hl_group = "Comment",
    fg_default = "#8d9eb2",
    bg_default = "#334152",
  })

  local collector, initial_targets = Collector.new(matcher, origin.lines, origin.cursor)

  local tbl = {
    _window_id = window_id,
    _cursor = origin.cursor,
    _origin = origin,
    _match_highlight = HlFactory.new("reacher", bufnr),
    _cursor_highlight = HlFactory.new("reacher_cursor", bufnr),
    _collector = collector,
    _targets = initial_targets,
  }
  return setmetatable(tbl, Overlay), nil
end

function Overlay.update(self, input_line)
  local targets = self._collector:collect(input_line)

  local highlighter = self._match_highlight:reset()
  for _, target in targets:iter() do
    target:highlight(highlighter, "ReacherMatch")
  end

  self:_update_cursor(targets:match(self._cursor))
end

function Overlay.close(self)
  self._origin:enter()
  windowlib.close(self._window_id)
end

function Overlay.finish(self)
  local target = self._targets:current()
  if target == nil then
    return
  end

  local mode = vim.api.nvim_get_mode().mode
  return function()
    return self._origin:jump(target.row, target.column, mode)
  end
end

function Overlay.move_cursor(self, action_name)
  local targets = self._targets[action_name](self._targets)
  self:_update_cursor(targets)
end

function Overlay._update_cursor(self, targets)
  local highlighter = self._cursor_highlight:reset()

  self._targets = targets
  local target = targets:current()
  if target == nil then
    return
  end
  target:highlight(highlighter, "ReacherCurrentMatch")
end

Overlay.hl_group_script = table.concat({
  highlightlib.link("ReacherMatch", "Directory"),
  highlightlib.link("ReacherCurrentMatchInsert", "IncSearch"),
  highlightlib.link("ReacherCurrentMatchNormal", "Search"),
}, "\n")

return M
