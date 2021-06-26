local repository = require("reacher.lib.repository").Repository.new("view")
local Overlays = require("reacher.view.overlay").Overlays
local Inputter = require("reacher.view.inputter").Inputter
local RowRange = require("reacher.model.row_range").RowRange
local Origin = require("reacher.view.origin").Origin
local OldMode = require("reacher.model.old_mode").OldMode
local modelib = require("reacher.lib.mode")
local vim = vim

local M = {}

local View = {}
View.__index = View
M.View = View

function View.new(matcher, current_origin, other_origins, was_visual_mode, opts)
  local overlays = Overlays.open(matcher, current_origin, other_origins)
  local inputter = Inputter.open(function(input_line)
    overlays:update(input_line)
  end, opts.input)

  local tbl = {
    _overlays = overlays,
    _inputter = inputter,
    _was_visual_mode = was_visual_mode,
    _closed = false,
  }
  local self = setmetatable(tbl, View)

  repository:set(inputter.window_id, self)
end

function View.open_one(matcher, opts)
  local old_mode = OldMode.to_normal_mode()
  local bufnr = vim.api.nvim_get_current_buf()
  local window_id = vim.api.nvim_get_current_win()
  local row_range = RowRange.new(window_id, opts.first_row, opts.last_row)
  local current_origin, err = Origin.new(window_id, old_mode, bufnr, row_range)
  if err ~= nil then
    return err
  end
  View.new(matcher, current_origin, {}, old_mode.is_visual, opts)
end

function View.open_multiple(matcher, opts)
  local current_bufnr = vim.api.nvim_get_current_buf()
  local current_window_id = vim.api.nvim_get_current_win()

  local old_mode = OldMode.to_normal_mode()
  local old_modes = {[current_bufnr] = old_mode}
  local normal_mode = OldMode.normal()

  local current_origin
  local other_origins = {}
  for _, window_id in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local bufnr = vim.api.nvim_win_get_buf(window_id)
    local origin, err = Origin.new(window_id, old_modes[bufnr] or normal_mode, bufnr, RowRange.new(window_id))
    if err ~= nil then
      return err
    end
    if window_id == current_window_id then
      current_origin = origin
    else
      table.insert(other_origins, origin)
    end
  end

  View.new(matcher, current_origin, other_origins, old_mode.is_visual, opts)
end

function View.recall_history(self, offset)
  self._inputter:recall_history(offset)
end

function View.save_history(self, ...)
  self._inputter:save_history(...)
end

function View.close(self, is_cancel)
  self._closed = true

  self._inputter:close(is_cancel)
  self._overlays:close()

  repository:delete(self._inputter.window_id)
end

function View.cancel(self)
  -- HACK: guard for firing autocmd many times
  if self._closed then
    return
  end

  self:save_history()
  self:close(true)

  if self._was_visual_mode then
    local mode = vim.api.nvim_get_mode().mode
    modelib.restore_visual_mode(true, mode)
  end
end

function View.finish(self)
  self:save_history(true)
  local jump = self._overlays:finish()

  local is_cancel = jump == nil
  self:close(is_cancel)

  if self._was_visual_mode then
    modelib.restore_visual_mode(is_cancel)
  end

  if jump ~= nil then
    return jump()
  end
end

function View.move_cursor(self, action_name)
  self._overlays:move_cursor(action_name)
end

function View.get(id)
  return repository:get(id)
end

function View.current()
  local id = vim.api.nvim_get_current_win()
  return View.get(id)
end

return M
