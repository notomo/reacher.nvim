local repository = require("reacher.lib.repository").Repository.new("view")
local Overlay = require("reacher.view.overlay").Overlay
local Inputter = require("reacher.view.inputter").Inputter
local RowRange = require("reacher.view.row_range").RowRange
local vim = vim

local M = {}

local View = {}
View.__index = View
M.View = View

function View.open(matcher, opts)
  local source_bufnr = vim.api.nvim_get_current_buf()

  local row_range = RowRange.new(opts.first_row, opts.last_row)
  local overlay, err = Overlay.open(matcher, source_bufnr, row_range)
  if err ~= nil then
    return err
  end

  local inputter = Inputter.open(function(input_line)
    overlay:update(input_line)
  end, opts.input)

  local tbl = {_overlay = overlay, _inputter = inputter}
  local view = setmetatable(tbl, View)

  repository:set(inputter.window_id, view)
end

function View.recall_history(self, offset)
  self._inputter:recall_history(offset)
end

function View.close(self, is_cancel)
  self._inputter:close(is_cancel)
  self._overlay:close()

  repository:delete(self._inputter.window_id)
end

function View.finish(self)
  local jump = self._overlay:finish()

  local is_cancel = jump == nil
  self:close(is_cancel)

  if jump ~= nil then
    return jump()
  end
end

function View.move(self, name)
  self._overlay[name](self._overlay)
end

function View.get(id)
  return repository:get(id)
end

function View.current()
  local id = vim.api.nvim_get_current_win()
  return View.get(id)
end

return M
