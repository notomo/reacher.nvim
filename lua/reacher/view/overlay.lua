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

  local bufnr = vim.api.nvim_create_buf(false, true)
  local window_id = origin:copy_to_floating_win(bufnr)

  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_win_set_option(window_id, "winhighlight", "Normal:ReacherBackground")

  local positions = source.collect(source_bufnr, origin.first_row, origin.last_row)

  local tbl = {
    _window_id = window_id,
    _origin = origin,
    _bufnr = bufnr,
    _row_offset = origin.first_row - 1,
    _all_positions = positions,
    _hl_factory = HlFactory.new("reacher", bufnr),
    _cursor_hl_factory = HlFactory.new("reacher-cursor", bufnr),
    _positions = {},
  }
  local overlay = setmetatable(tbl, Overlay)

  highlightlib.set_background(origin.id, {
    fg_hl_group = "Comment",
    fg_default = "#8d9eb2",
    bg_default = "#334152",
  })
  overlay:update("")

  return overlay
end

function Overlay.update(self, input_line)
  local positions = {}
  local root = Node.new()
  for _, pos in ipairs(self._all_positions) do
    if vim.startswith(pos.line, input_line) then
      table.insert(positions, pos)

      root:add(#positions, pos.line)
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

  local highlighter = self._hl_factory:reset()
  local cursor_highlighter = self._cursor_hl_factory:reset()

  self._index = 1

  local distance = Distance.new(self._origin.cursor, positions[self._index])
  for i, pos in ipairs(positions) do
    local d = Distance.new(self._origin.cursor, pos)
    if d < distance then
      distance = d
      self._index = i
    end

    highlighter:add("WarningMsg", pos.row - self._row_offset - 1, pos.column, pos.column + 1)

    local idx = root:search(i, pos.line)
    if idx ~= nil then
      highlighter:add("String", pos.row - self._row_offset - 1, pos.column + idx - 1, pos.column + idx)
    end
  end

  local pos = self._positions[self._index]
  cursor_highlighter:add("Todo", pos.row - self._row_offset - 1, pos.column, pos.column + 1)
end

function Overlay.close(self)
  windowlib.close(self._window_id)
  windowlib.enter(self._origin.id)
end

function Overlay.finish(self, pos)
  pos = pos or self._positions[self._index]
  vim.api.nvim_set_current_win(self._origin.id)
  vim.api.nvim_win_set_cursor(self._origin.id, {pos.row, pos.column + 1})
end

function Overlay.next(self)
  self._index = (self._index % #self._positions) + 1
  local pos = self._positions[self._index]
  self._cursor_hl_factory:reset():add("Todo", pos.row - self._row_offset - 1, pos.column, pos.column + 1)
end

function Overlay.prev(self)
  self._index = ((self._index - 1) % #self._positions - 1) % #self._positions + 1
  local pos = self._positions[self._index]
  self._cursor_hl_factory:reset():add("Todo", pos.row - self._row_offset - 1, pos.column, pos.column + 1)
end

return M
