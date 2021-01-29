local repository = require("reacher.lib.repository").Repository.new("view")
local Overlay = require("reacher.view.overlay").Overlay
local Inputter = require("reacher.view.inputter").Inputter

local M = {}

local View = {}
View.__index = View
M.View = View

function View.open(source)
  local source_bufnr = vim.api.nvim_get_current_buf()

  local overlay, err = Overlay.open(source, source_bufnr)
  if err ~= nil then
    return err
  end

  local inputter = Inputter.open(function(input_line)
    overlay:update(input_line)
  end)

  local tbl = {_overlay = overlay, _inputter = inputter}
  local view = setmetatable(tbl, View)

  repository:set(inputter.window_id, view)
end

function View.close(self)
  self._inputter:close()
  self._overlay:close()

  repository:delete(self._inputter.window_id)
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
