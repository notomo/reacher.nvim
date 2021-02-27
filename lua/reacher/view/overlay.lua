local windowlib = require("reacher.lib.window")
local highlightlib = require("reacher.lib.highlight")
local HlFactory = require("reacher.lib.highlight").HlFactory
local Origin = require("reacher.view.origin").Origin
local Input = require("reacher.model.input").Input
local vim = vim

local M = {}

local Overlay = {}
Overlay.__index = Overlay
M.Overlay = Overlay

function Overlay.open(source, source_bufnr)
  local origin = Origin.new(source_bufnr)

  local targets, err = source:collect(origin.lines)
  if err ~= nil then
    return nil, err
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  local window_id = origin:copy_to_floating_win(bufnr)

  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].modifiable = false
  vim.wo[window_id].winhighlight = "Normal:ReacherBackground"

  local tbl = {
    _window_id = window_id,
    _cursor = origin.cursor,
    _origin = origin,
    _match_hl = HlFactory.new("reacher", bufnr),
    _cursor_hl = HlFactory.new("reacher_cursor", bufnr),
    _all_targets = targets,
    _targets = targets,
    _input = nil,
    _cursor_width = 1,
  }
  local overlay = setmetatable(tbl, Overlay)

  highlightlib.link("ReacherCurrentMatch", "ReacherCurrentMatchInsert", true)
  highlightlib.set_background("ReacherBackground", origin.window_id, {
    fg_hl_group = "Comment",
    fg_default = "#8d9eb2",
    bg_default = "#334152",
  })
  overlay:update("")

  return overlay, nil
end

function Overlay.update(self, line)
  local input = Input.new(line)
  if input == self._input then
    return
  end
  self._input = input

  self._cursor_width = #input.str
  if self._cursor_width == 0 then
    self._cursor_width = 1
  end

  local targets = self._all_targets:filter(function(target)
    local str = target.str
    if input.ignorecase then
      str = str:lower()
    end
    return vim.startswith(str, input.str)
  end)
  local highlighter = self._match_hl:reset()
  for _, target in targets:iter() do
    highlighter:add("ReacherMatch", target.row - 1, target.column, target.column + self._cursor_width)
  end

  self:_update_cursor(targets:match(self._cursor))
end

function Overlay.close(self)
  self._origin:enter()
  windowlib.close(self._window_id)
end

function Overlay.finish(self, target)
  target = target or self._targets:current()
  if target == nil then
    return
  end

  local mode = vim.api.nvim_get_mode().mode
  return function()
    self._origin:jump(target.row, target.column, mode)
  end
end

function Overlay.first(self)
  self:_update_cursor(self._targets:first())
end

function Overlay.next(self)
  self:_update_cursor(self._targets:next())
end

function Overlay.prev(self)
  self:_update_cursor(self._targets:prev())
end

function Overlay.last(self)
  self:_update_cursor(self._targets:last())
end

function Overlay._update_cursor(self, targets)
  local highlighter = self._cursor_hl:reset()

  self._targets = targets
  local target = targets:current()
  if target == nil then
    return
  end
  highlighter:add("ReacherCurrentMatch", target.row - 1, target.column, target.column + self._cursor_width)
end

highlightlib.link("ReacherMatch", "Directory")
highlightlib.link("ReacherCurrentMatchInsert", "IncSearch")
highlightlib.link("ReacherCurrentMatchNormal", "Search")

return M
