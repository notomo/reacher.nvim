local View = require("reacher.view").View
local Source = require("reacher.source").Source
local messagelib = require("reacher.lib.message")
local vim = vim

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
    return messagelib.warn(msg)
  end
end

function Command.start(name)
  vim.validate({name = {name, "string", true}})

  local old = View.current()
  if old ~= nil then
    old:close()
  end

  local source, err = Source.new(name or "word")
  if err ~= nil then
    return err
  end

  return View.open(source)
end

function Command.move(action_name)
  vim.validate({action_name = {action_name, "string"}})

  local view = View.current()
  if view == nil then
    return "is not started"
  end

  view:move(action_name)
end

function Command.finish()
  local view = View.current()
  if view == nil then
    return "is not started"
  end
  view:finish()
end

function Command.cancel()
  local view = View.current()
  if view == nil then
    return
  end
  view:close(true)
end

function Command.close(id, is_cancel)
  vim.validate({id = {id, "number"}})

  local view = View.get(id)
  if view == nil then
    return
  end

  view:close(is_cancel)
end

return M
