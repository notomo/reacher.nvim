local repository = require("reacher/lib/repository").Repository.new("view")
local Overlay = require("reacher/view/overlay").Overlay
local Inputer = require("reacher/view/inputer").Inputer

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

  local inputer = Inputer.open(function(input_line)
    overlay:update(input_line)
  end)

  local tbl = {_overlay = overlay, _inputer = inputer}
  local view = setmetatable(tbl, View)

  repository:set(inputer.window_id, view)
end

function View.close(self)
  self._inputer:close()
  self._overlay:close()

  repository:delete(self._inputer.window_id)
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
