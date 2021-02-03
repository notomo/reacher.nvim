local Command = require("reacher.command").Command

local M = {}

function M.start()
  return Command.new("start")
end

function M.first()
  return Command.new("move", "first")
end

function M.prev()
  return Command.new("move", "prev")
end

function M.next()
  return Command.new("move", "next")
end

function M.last()
  return Command.new("move", "last")
end

function M.finish()
  return Command.new("finish")
end

function M.cancel()
  return Command.new("cancel")
end

return M
