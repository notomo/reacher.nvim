local modulelib = require("reacher/lib/module")
local View = require("reacher/view").View

local M = {}

local Command = {}

function Command.start()
  local source_name = "word" -- TODO
  local source = modulelib.find_source(source_name)
  if source == nil then
    return "[reacher] not found source: " .. source_name
  end
  View.open(source)
end

function Command.next()
  local view = View.current()
  if view == nil then
    return
  end
  view:next()
end

function Command.prev()
  local view = View.current()
  if view == nil then
    return
  end
  view:prev()
end

function Command.finish()
  local view = View.current()
  if view == nil then
    return
  end
  view:finish()
end

M.close = function(id)
  local view = View.get(id)
  if view == nil then
    return
  end
  view:close()
end

M.main = function(...)
  local cmd_name = ({...})[1] or "start"
  local cmd = Command[cmd_name]
  if cmd == nil then
    return vim.api.nvim_err_write("[reacher] not found command: " .. cmd_name .. "\n")
  end

  local _, err = xpcall(cmd, debug.traceback)
  if err ~= nil then
    return vim.api.nvim_err_write(err .. "\n")
  end
end

return M
