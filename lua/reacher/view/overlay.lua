local windowlib = require("reacher/lib/window")
local highlightlib = require("reacher/lib/highlight")
local HlFactory = require("reacher/lib/highlight").HlFactory
local Origin = require("reacher/view/origin").Origin
local Node = require("reacher/tree").Node
local Distance = require("reacher/distance").Distance

local M = {}

local Overlay = {}
Overlay.__index = Overlay
M.Overlay = Overlay

function Overlay.open(source, source_bufnr)
  local origin = Origin.new(source_bufnr)

  local positions = source.collect(origin.lines)
  if #positions == 0 then
    return nil, "no targets"
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  local window_id = origin:copy_to_floating_win(bufnr)

  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_win_set_option(window_id, "winhighlight", "Normal:ReacherBackground")

  local cursor = vim.api.nvim_win_get_cursor(window_id)
  local tbl = {
    _window_id = window_id,
    _cursor = {row = cursor[1], column = cursor[2]},
    _origin = origin,
    _hl_factory = HlFactory.new("reacher", bufnr),
    _cursor_hl_factory = HlFactory.new("reacher-cursor", bufnr),
    _all_positions = positions,
    _positions = {},
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
  local positions = {}
  local root = Node.new()
  input_line = input_line:lower()
  for _, pos in ipairs(self._all_positions) do
    local line = pos.line:lower()
    if vim.startswith(line, input_line) then
      table.insert(positions, pos)
      root:add(#positions, line)
    end
  end
  self._positions = positions

  if #positions == 1 then
    self:finish(positions[1])
    return
  elseif #positions == 0 then
    self:close()
    return
  end

  local index = 1
  local distance = Distance.new(self._cursor, positions[index])
  local highlighter = self._hl_factory:reset()
  for i, pos in ipairs(positions) do
    local d = Distance.new(self._cursor, pos)
    if d < distance then
      distance = d
      index = i
    end

    highlighter:add("ReacherMatch", pos.row - 1, pos.column, pos.column + 1)

    local idx = root:search(i, pos.line:lower())
    if idx ~= nil then
      highlighter:add("ReacherEnd", pos.row - 1, pos.column + idx - 1, pos.column + idx)
    end
  end

  self:_update_cursor(index)
end

function Overlay.close(self)
  windowlib.enter(self._origin.id)
  windowlib.close(self._window_id)
end

function Overlay.finish(self, pos)
  pos = pos or self._positions[self._index]
  windowlib.enter(self._origin.id)
  vim.api.nvim_command("normal! m'")
  vim.api.nvim_win_set_cursor(self._origin.id, {
    pos.row + self._origin.row_offset,
    pos.column + self._origin.column_offset + 1,
  })
end

function Overlay.first(self)
  self:_update_cursor(1)
end

function Overlay.next(self)
  local index = (self._index % #self._positions) + 1
  self:_update_cursor(index)
end

function Overlay.prev(self)
  local index = ((self._index - 1) % #self._positions - 1) % #self._positions + 1
  self:_update_cursor(index)
end

function Overlay.last(self)
  self:_update_cursor(#self._positions)
end

function Overlay._update_cursor(self, index)
  local pos = self._positions[index]
  if pos == nil then
    return
  end
  self._index = index

  local highlighter = self._cursor_hl_factory:reset()
  highlighter:add("ReacherCurrentMatch", pos.row - 1, pos.column, pos.column + 1)

  local prev_idx = ((index - 1) % #self._positions - 1) % #self._positions + 1
  if prev_idx ~= index then
    local prev_pos = self._positions[prev_idx]
    highlighter:add("ReacherPrevMatch", prev_pos.row - 1, prev_pos.column, prev_pos.column + 1)
  end

  local next_idx = (index % #self._positions) + 1
  if next_idx ~= index then
    local next_pos = self._positions[next_idx]
    highlighter:add("ReacherNextMatch", next_pos.row - 1, next_pos.column, next_pos.column + 1)
  end
end

highlightlib.link("ReacherEnd", "String")
highlightlib.link("ReacherMatch", "WarningMsg")
highlightlib.link("ReacherCurrentMatch", "Todo")
highlightlib.link("ReacherPrevMatch", "Statement")
highlightlib.link("ReacherNextMatch", "Statement")

return M
