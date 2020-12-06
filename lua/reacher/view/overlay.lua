local windowlib = require("reacher/lib/window")
local highlightlib = require("reacher/lib/highlight")
local HlFactory = require("reacher/lib/highlight").HlFactory
local Origin = require("reacher/view/origin").Origin
local Node = require("reacher/tree").Node
local Distance = require("reacher/distance").Distance
local Position = require("reacher/position").Position

local M = {}

local Overlay = {}
Overlay.__index = Overlay
M.Overlay = Overlay

function Overlay.open(source, source_bufnr)
  local origin = Origin.new(source_bufnr)

  local targets = source.collect(origin.lines)
  if #targets == 0 then
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
    _all_targets = targets,
    _targets = {},
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
  local targets = {}
  local root = Node.new()
  input_line = input_line:lower()
  for _, target in ipairs(self._all_targets) do
    if vim.startswith(target.str, input_line) then
      table.insert(targets, target)
      root:add(#targets, target.str)
    end
  end
  self._targets = targets

  if #targets == 1 then
    self:finish(targets[1])
    return
  elseif #targets == 0 then
    self:close()
    return
  end

  local index = 1
  local distance = Distance.new(self._cursor, targets[index])
  local highlighter = self._hl_factory:reset()
  for i, target in ipairs(targets) do
    local d = Distance.new(self._cursor, target)
    if d < distance then
      distance = d
      index = i
    end

    highlighter:add("ReacherMatch", target.row - 1, target.column, target.column + 1)

    local idx = root:search(i, target.str)
    if idx ~= nil then
      highlighter:add("ReacherEnd", target.row - 1, target.column + idx - 1, target.column + idx)
    end
  end

  self:_update_cursor(index)
end

function Overlay.close(self)
  windowlib.enter(self._origin.id)
  windowlib.close(self._window_id)
end

function Overlay.finish(self, target)
  target = target or self._targets[self._index]
  windowlib.enter(self._origin.id)
  vim.api.nvim_command("normal! m'")
  vim.api.nvim_win_set_cursor(self._origin.id, {
    target.row + self._origin.offset.row,
    target.column + self._origin.offset.column + 1, -- + 1 for stopinsert
  })
end

function Overlay.first(self)
  self:_update_cursor(1)
end

function Overlay.next(self)
  local index = (self._index % #self._targets) + 1
  self:_update_cursor(index)
end

function Overlay.prev(self)
  local index = ((self._index - 1) % #self._targets - 1) % #self._targets + 1
  self:_update_cursor(index)
end

function Overlay.last(self)
  self:_update_cursor(#self._targets)
end

function Overlay._update_cursor(self, index)
  local target = self._targets[index]
  if target == nil then
    return
  end
  self._index = index

  local highlighter = self._cursor_hl_factory:reset()
  highlighter:add("ReacherCurrentMatch", target.row - 1, target.column, target.column + 1)

  local prev_idx = ((index - 1) % #self._targets - 1) % #self._targets + 1
  if prev_idx ~= index then
    local prev_target = self._targets[prev_idx]
    highlighter:add("ReacherPrevMatch", prev_target.row - 1, prev_target.column, prev_target.column + 1)
  end

  local next_idx = (index % #self._targets) + 1
  if next_idx ~= index then
    local next_target = self._targets[next_idx]
    highlighter:add("ReacherNextMatch", next_target.row - 1, next_target.column, next_target.column + 1)
  end
end

highlightlib.link("ReacherEnd", "String")
highlightlib.link("ReacherMatch", "WarningMsg")
highlightlib.link("ReacherCurrentMatch", "Todo")
highlightlib.link("ReacherPrevMatch", "Statement")
highlightlib.link("ReacherNextMatch", "Statement")

return M
