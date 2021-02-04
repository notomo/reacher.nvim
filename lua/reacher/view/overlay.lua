local windowlib = require("reacher.lib.window")
local highlightlib = require("reacher.lib.highlight")
local HlFactory = require("reacher.lib.highlight").HlFactory
local Origin = require("reacher.view.origin").Origin
local Distance = require("reacher.model.distance").Distance
local Position = require("reacher.model.position").Position
local Targets = require("reacher.model.target").Targets
local Target = require("reacher.model.target").Target
local Inputs = require("reacher.model.input").Inputs

local M = {}

local Overlay = {}
Overlay.__index = Overlay
M.Overlay = Overlay

function Overlay.open(source, source_bufnr)
  local origin = Origin.new(source_bufnr)

  local raw_targets = source.collect(origin.lines)
  if #raw_targets == 0 then
    return nil, "no targets"
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  local window_id = origin:copy_to_floating_win(bufnr)

  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].modifiable = false
  vim.wo[window_id].winhighlight = "Normal:ReacherBackground"

  local tbl = {
    _window_id = window_id,
    _cursor = Position.cursor(window_id),
    _origin = origin,
    _lines = vim.tbl_map(function(line)
      return line:lower()
    end, origin.lines),
    _match_hl = HlFactory.new("reacher", bufnr),
    _cursor_hl = HlFactory.new("reacher-cursor", bufnr),
    _all_targets = Targets.new(raw_targets),
    _targets = Targets.new(raw_targets),
    _inputs = nil,
    _cursor_width = 1,
  }
  local overlay = setmetatable(tbl, Overlay)

  highlightlib.link("ReacherCurrentMatch", "ReacherCurrentMatchInsert", true)
  highlightlib.set_background("ReacherBackground", origin.id, {
    fg_hl_group = "Comment",
    fg_default = "#8d9eb2",
    bg_default = "#334152",
  })
  overlay:update("")

  return overlay, nil
end

function Overlay.update(self, input_line)
  local inputs = Inputs.parse(input_line)
  if inputs == self._inputs then
    return
  end
  self._inputs = inputs

  local targets = self._all_targets:filter(function(target)
    return vim.startswith(target.str, inputs.head)
  end)
  targets = targets:filter(function(target)
    return inputs:is_included_in(self._lines[target.row])
  end)

  self._cursor_width = #inputs.head
  if self._cursor_width == 0 then
    self._cursor_width = 1
  end

  local highlighter = self._match_hl:reset()

  for _, target in targets:iter() do
    local ranges = inputs:matched(self._lines[target.row])
    for _, r in ipairs(ranges) do
      highlighter:add("ReacherInputMatch", target.row - 1, r[1] - 1, r[2])
    end
  end

  local distance = Distance.new(self._cursor, targets:current() or Target.zero())
  local index = 1
  for i, target in targets:iter() do
    local d = Distance.new(self._cursor, target)
    if d < distance then
      distance = d
      index = i
    end
    highlighter:add("ReacherMatch", target.row - 1, target.column, target.column + self._cursor_width)
  end

  self:_update_cursor(targets:to(index))
end

function Overlay.close(self)
  windowlib.enter(self._origin.id)
  windowlib.close(self._window_id)
end

function Overlay.finish(self, target)
  target = target or self._targets:current()
  if target == nil then
    return
  end

  local insert_offset = 1 -- for stopinsert
  if vim.api.nvim_get_mode().mode == "n" then
    insert_offset = 0
  end

  return function()
    local row = target.row + self._origin.offset.row
    local column = target.column + self._origin.offset.column + insert_offset
    windowlib.jump(self._origin.id, row, column)
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
highlightlib.link("ReacherCurrentMatchNormal", "Todo")
highlightlib.link("ReacherInputMatch", "Conditional")

return M
