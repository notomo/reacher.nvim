local Command = require("reacher.command").Command

local M = {}

function M.start(name)
  Command.new("start", name)
end

function M.first()
  Command.new("move", "first")
end

function M.prev()
  Command.new("move", "prev")
end

function M.next()
  Command.new("move", "next")
end

function M.last()
  Command.new("move", "last")
end

function M.finish()
  Command.new("finish")
end

function M.cancel()
  Command.new("cancel")
end

return M
