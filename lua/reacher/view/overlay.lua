local windowlib = require("reacher/lib/window")
local highlightlib = require("reacher/lib/highlight")
local HlFactory = require("reacher/lib/highlight").HlFactory
local Origin = require("reacher/view/origin").Origin
local Node = require("reacher/model/node").Node
local Distance = require("reacher/model/distance").Distance
local Position = require("reacher/model/position").Position
local Targets = require("reacher/model/target").Targets

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

  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_win_set_option(window_id, "winhighlight", "Normal:ReacherBackground")

  local tbl = {
    _window_id = window_id,
    _cursor = Position.cursor(window_id),
    _origin = origin,
    _hl_factory = HlFactory.new("reacher", bufnr),
    _cursor_hl_factory = HlFactory.new("reacher-cursor", bufnr),
    _all_targets = Targets.new(raw_targets),
    _targets = Targets.new(raw_targets),
  }
  local overlay = setmetatable(tbl, Overlay)

  highlightlib.set_background("ReacherBackground", origin.id, {
    fg_hl_group = "Comment",
    fg_default = "#8d9eb2",
    bg_default = "#334152",
  })
  overlay:update("")

  return overlay, nil
end

function Overlay.update(self, input_line)
  input_line = input_line:lower()
  self._targets = self._all_targets:filter(function(target)
    return vim.startswith(target.str, input_line)
  end)

  local length = self._targets:length()
  if length == 1 then
    self:finish(self._targets[1])
    return
  elseif length == 0 then
    self:close()
    return
  end

  self._cursor_width = #input_line
  if self._cursor_width == 0 then
    self._cursor_width = 1
  end

  local root = Node.new(vim.tbl_map(function(target)
    return target.str
  end, self._targets:values()))

  local distance = Distance.new(self._cursor, self._targets:current())
  local highlighter = self._hl_factory:reset()
  local index = 1
  for i, target in self._targets:iter_all() do
    local d = Distance.new(self._cursor, target)
    if d < distance then
      distance = d
      index = i
    end

    highlighter:add("ReacherMatch", target.row - 1, target.column, target.column + self._cursor_width)

    local idx = root:search(i, target.str)
    if idx ~= nil then
      highlighter:add("ReacherEnd", target.row - 1, target.column + idx - 1, target.column + idx)
    end
  end

  self:_update_cursor(self._targets:to(index))
end

function Overlay.close(self)
  windowlib.enter(self._origin.id)
  windowlib.close(self._window_id)
end

function Overlay.finish(self, target)
  target = target or self._targets:current()
  windowlib.enter(self._origin.id)
  vim.api.nvim_command("normal! m'")
  vim.api.nvim_win_set_cursor(self._origin.id, {
    target.row + self._origin.offset.row,
    target.column + self._origin.offset.column + 1, -- + 1 for stopinsert
  })
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
  local target = targets:current()
  if target == nil then
    return
  end
  self._targets = targets

  local highlighter = self._cursor_hl_factory:reset()
  highlighter:add("ReacherCurrentMatch", target.row - 1, target.column, target.column + self._cursor_width)

  local prev_target = targets:prev():current()
  if prev_target ~= target then
    highlighter:add("ReacherPrevMatch", prev_target.row - 1, prev_target.column, prev_target.column + self._cursor_width)
  end

  local next_target = targets:next():current()
  if next_target ~= target then
    highlighter:add("ReacherNextMatch", next_target.row - 1, next_target.column, next_target.column + self._cursor_width)
  end
end

highlightlib.link("ReacherEnd", "String")
highlightlib.link("ReacherMatch", "WarningMsg")
highlightlib.link("ReacherCurrentMatch", "Todo")
highlightlib.link("ReacherPrevMatch", "Statement")
highlightlib.link("ReacherNextMatch", "Statement")

return M
