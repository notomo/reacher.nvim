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

Command.last_call = nil

function Command.start_one(raw_opts)
  local msg = messagelib.validate({opts = {raw_opts, "table", true}})
  if msg then
    return msg
  end

  local old = View.current()
  if old then
    old:close()
  end

  local opts = vim.tbl_deep_extend("force", {matcher_opts = {name = "regex"}}, raw_opts or {})
  local matcher, err = Matcher.new(opts.matcher_opts.name)
  if err then
    return err
  end

  local call = function(extend_opts)
    return View.open_one(matcher, vim.tbl_deep_extend("force", opts, extend_opts or {}))
  end
  Command.last_call = call

  return call()
end

function Command.start_multiple(raw_opts)
  local msg = messagelib.validate({opts = {raw_opts, "table", true}})
  if msg then
    return msg
  end

  local old = View.current()
  if old then
    old:close()
  end

  local opts = vim.tbl_deep_extend("force", {matcher_opts = {name = "regex"}}, raw_opts or {})
  local matcher, err = Matcher.new(opts.matcher_opts.name)
  if err then
    return err
  end

  local call = function(extend_opts)
    return View.open_multiple(matcher, vim.tbl_deep_extend("force", opts, extend_opts or {}))
  end
  Command.last_call = call

  return call()
end

function Command.again(extend_opts)
  local msg = messagelib.validate({opts = {extend_opts, "table", true}})
  if msg then
    return msg
  end

  local old = View.current()
  if old then
    old:close()
  end

  if not Command.last_call then
    return Command.start_one(extend_opts)
  end

  return Command.last_call(extend_opts)
end

function Command.move_cursor(action_name)
  vim.validate({action_name = {action_name, "string"}})

  local view = View.current()
  if not view then
    return IsNotStartedErr
  end

  view:move_cursor(action_name)
end

function Command.finish()
  local view = View.current()
  if not view then
    return IsNotStartedErr
  end

  local row, column = view:finish()
  if row then
    messagelib.info(("jumped to (%d, %d)"):format(row, column))
  end
end

function Command.recall_history(offset)
  vim.validate({offset = {offset, "number"}})
  local view = View.current()
  if not view then
    return IsNotStartedErr
  end
  view:recall_history(offset)
end

function Command.cancel()
  local view = View.current()
  if not view then
    return
  end
  view:cancel()
  messagelib.info("canceled")
end

function Command.close(id)
  vim.validate({id = {id, "number"}})
  local view = View.get(id)
  if not view then
    return
  end
  view:cancel()
end

return M
