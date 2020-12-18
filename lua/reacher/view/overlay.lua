local windowlib = require("reacher/lib/window")
local highlightlib = require("reacher/lib/highlight")
local HlFactory = require("reacher/lib/highlight").HlFactory
local Origin = require("reacher/view/origin").Origin
local Distance = require("reacher/model/distance").Distance
local Position = require("reacher/model/position").Position
local Targets = require("reacher/model/target").Targets
local Target = require("reacher/model/target").Target

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

  local inputs = vim.tbl_filter(function(input)
    return input ~= ""
  end, vim.split(input_line, "%s+"))
  local input_head = table.remove(inputs, 1) or ""

  self._targets = self._all_targets:filter(function(target)
    return vim.startswith(target.str, input_head)
  end)

  if #inputs > 0 then
    self._targets = self._targets:filter(function(target)
      local line = self._lines[target.row]
      for _, input in ipairs(inputs) do
        local ok = line:find(input, 1, true)
        if not ok then
          return false
        end
      end
      return true
    end)
  end

  self._cursor_width = #input_head
  if self._cursor_width == 0 then
    self._cursor_width = 1
  end

  local highlighter = self._hl_factory:reset()

  for _, target in self._targets:iter_all() do
    local positions = {}
    local line = self._lines[target.row]
    for _, input in ipairs(inputs) do
      local s
      local e = 0
      repeat
        s, e = line:find(input, e + 1, true)
        if s ~= nil then
          table.insert(positions, {s, e})
        end
      until s == nil
    end
    for _, pos in ipairs(positions) do
      highlighter:add("ReacherInputMatch", target.row - 1, pos[1] - 1, pos[2])
    end
  end

  local distance = Distance.new(self._cursor, self._targets:current() or Target.new(0, 0, ""))
  local index = 1
  for i, target in self._targets:iter_all() do
    local d = Distance.new(self._cursor, target)
    if d < distance then
      distance = d
      index = i
    end
    highlighter:add("ReacherMatch", target.row - 1, target.column, target.column + self._cursor_width)
  end

  self:_update_cursor(self._targets:to(index))
end

function Overlay.close(self)
  windowlib.enter(self._origin.id)
  windowlib.close(self._window_id)
end

function Overlay.finish(self, target)
  target = target or self._targets:current()
  if target == nil then
    return self:close()
  end

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
  local highlighter = self._cursor_hl_factory:reset()

  self._targets = targets
  local target = targets:current()
  if target == nil then
    return
  end
  highlighter:add("ReacherCurrentMatch", target.row - 1, target.column, target.column + self._cursor_width)
end

highlightlib.link("ReacherMatch", "WarningMsg")
highlightlib.link("ReacherCurrentMatch", "Todo")
highlightlib.link("ReacherInputMatch", "Conditional")

return M
