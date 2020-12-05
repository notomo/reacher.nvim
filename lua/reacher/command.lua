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

local move = function(name)
  local view = View.current()
  if view == nil then
    return
  end
  view:move(name)
end

function Command.first()
  move("first")
end

function Command.prev()
  move("prev")
end

function Command.next()
  move("next")
end

function Command.last()
  move("last")
end

function Command.finish()
  move("finish")
end

M.close = function(id)
  local view = View.get(id)
  if view == nil then
    return
  end
  view:close()
end

M.main = function(...)
  local name = ({...})[1] or "start"
  local cmd = Command[name]
  if cmd == nil then
    return vim.api.nvim_err_write("[reacher] not found command: " .. name .. "\n")
  end

  local _, err = xpcall(cmd, debug.traceback)
  if err ~= nil then
    return vim.api.nvim_err_write(err .. "\n")
  end
end

return M
