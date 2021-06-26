local View = require("reacher.view").View
local Matcher = require("reacher.model.matcher").Matcher
local messagelib = require("reacher.lib.message")
local vim = vim

local M = {}

local Command = {}
Command.__index = Command
M.Command = Command

local IsNotStartedErr = "is not started"

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

function Command.start_one(raw_opts)
  local msg = messagelib.validate({opts = {raw_opts, "table", true}})
  if msg then
    return msg
  end

  local old = View.current()
  if old ~= nil then
    old:close()
  end

  local opts = vim.tbl_deep_extend("force", {matcher_opts = {name = "regex"}}, raw_opts or {})
  local matcher, err = Matcher.new(opts.matcher_opts.name)
  if err ~= nil then
    return err
  end

  return View.open_one(matcher, opts)
end

function Command.start_multiple(raw_opts)
  local msg = messagelib.validate({opts = {raw_opts, "table", true}})
  if msg then
    return msg
  end

  local old = View.current()
  if old ~= nil then
    old:close()
  end

  local opts = vim.tbl_deep_extend("force", {matcher_opts = {name = "regex"}}, raw_opts or {})
  local matcher, err = Matcher.new(opts.matcher_opts.name)
  if err ~= nil then
    return err
  end

  return View.open_multiple(matcher, opts)
end

function Command.move_cursor(action_name)
  vim.validate({action_name = {action_name, "string"}})

  local view = View.current()
  if view == nil then
    return IsNotStartedErr
  end

  view:move_cursor(action_name)
end

function Command.finish()
  local view = View.current()
  if view == nil then
    return IsNotStartedErr
  end

  local row, column = view:finish()
  if row ~= nil then
    messagelib.info(("jumped to (%d, %d)"):format(row, column))
  end
end

function Command.recall_history(offset)
  vim.validate({offset = {offset, "number"}})
  local view = View.current()
  if view == nil then
    return IsNotStartedErr
  end
  view:recall_history(offset)
end

function Command.cancel()
  local view = View.current()
  if view == nil then
    return
  end
  view:cancel()
  messagelib.info("canceled")
end

function Command.close(id)
  vim.validate({id = {id, "number"}})
  local view = View.get(id)
  if view == nil then
    return
  end
  view:cancel()
end

return M
