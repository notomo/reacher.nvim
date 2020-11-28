local repository = require("reacher/lib/repository")
local Overlay = require("reacher/view/overlay").Overlay
local Inputer = require("reacher/view/inputer").Inputer

local M = {}

local View = {}
View.__index = View
M.View = View

function View.open(source)
  local source_bufnr = vim.api.nvim_get_current_buf()

  local overlay = Overlay.open(source, source_bufnr)
  local inputer = Inputer.open(function(input_line)
    vim.schedule(function()
      overlay:update(input_line)
    end)
  end)

  local tbl = {_overlay = overlay, _inputer = inputer}
  local view = setmetatable(tbl, View)

  repository.set(inputer.window_id, view)

  return view
end

function View.close(self)
  self._inputer:close()
  self._overlay:close()

  repository.delete(self._inputer.window_id)
end

function View.finish(self)
  self._overlay:finish()
end

function View.get(id)
  return repository.get(id)
end

return M
