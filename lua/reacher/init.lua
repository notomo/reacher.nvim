local Command = require("reacher.command").Command

local M = {}

function M.start(opts)
  Command.new("start", opts)
end

function M.first()
  Command.new("move", "first")
end

function M.next()
  Command.new("move", "next")
end

function M.next_line()
  Command.new("move", "next_line")
end

function M.previous()
  Command.new("move", "previous")
end

function M.previous_line()
  Command.new("move", "previous_line")
end

function M.last()
  Command.new("move", "last")
end

function M.first_column()
  Command.new("move", "first_column")
end

function M.last_column()
  Command.new("move", "last_column")
end

function M.forward_history()
  Command.new("recall_history", 1)
end

function M.backward_history()
  Command.new("recall_history", -1)
end

function M.finish()
  Command.new("finish")
end

function M.cancel()
  Command.new("cancel")
end

return M
