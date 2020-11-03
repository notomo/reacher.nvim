local modulelib = require("reacher/lib/module")
local View = require("reacher/view").View

local M = {}

M.main = function(...)
  local source_name = ({...})[1] or "word"

  local f = function()
    local source = modulelib.find_source(source_name)
    if source == nil then
      return "[reacher] not found source: " .. source_name
    end
    return View.new(source):open()
  end

  local _, err = xpcall(f, debug.traceback)
  if err ~= nil then
    return vim.api.nvim_err_write(err .. "\n")
  end
end

return M
