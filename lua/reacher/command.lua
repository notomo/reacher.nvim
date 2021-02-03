local View = require("reacher.view").View
local modulelib = require("reacher.lib.module")
local messagelib = require("reacher.lib.message")

local M = {}

local Command = {}
Command.__index = Command
M.Command = Command

function Command.new(name, ...)
  local args = {...}
  local f = function()
    return Command[name](unpack(args))
  end

  local ok, msg = xpcall(f, debug.traceback)
  if not ok then
    return messagelib.error(msg)
  elseif msg then
    messagelib.warn(msg)
    return msg
  end
end

function Command.start()
  local old = View.current()
  if old ~= nil then
    old:close()
  end

  local name = "word"
  local source = modulelib.find("reacher.source." .. name)
  if source == nil then
    return "not found source: " .. name
  end

  local err = View.open(source)
  if err ~= nil then
    return err
  end
end

function Command.move(action_name)
  vim.validate({action_name = {action_name, "string"}})

  local view = View.current()
  if view == nil then
    return
  end

  view:move(action_name)
end

function Command.finish()
  local view = View.current()
  if view == nil then
    return
  end

  view:finish()
end

function Command.close(id)
  vim.validate({id = {id, "number"}})

  local view = View.get(id)
  if view == nil then
    return
  end

  view:close()
end

return M
