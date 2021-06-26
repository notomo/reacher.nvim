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

function View.open(matcher, opts)
  local old_mode = OldMode.to_normal_mode()
  local source_bufnr = vim.api.nvim_get_current_buf()
  local row_range = RowRange.new(opts.first_row, opts.last_row)
  local origin, err = Origin.new(old_mode, source_bufnr, row_range)
  if err ~= nil then
    return err
  end

  local overlays = Overlays.open(matcher, origin, {})
  local inputter = Inputter.open(function(input_line)
    overlays:update(input_line)
  end, opts.input)

  local tbl = {
    _overlays = overlays,
    _inputter = inputter,
    _was_visual_mode = old_mode.is_visual,
    _closed = false,
  }
  local view = setmetatable(tbl, View)

  repository:set(inputter.window_id, view)
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
