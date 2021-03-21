local Command = require("reacher.command").Command

local M = {}

function M.start(opts)
  Command.new("start", opts)
end

function M.first()
  Command.new("move_cursor", "first")
end

function M.next()
  Command.new("move_cursor", "next")
end

function M.next_line()
  Command.new("move_cursor", "next_line")
end

function M.previous()
  Command.new("move_cursor", "previous")
end

function M.previous_line()
  Command.new("move_cursor", "previous_line")
end

function M.last()
  Command.new("move_cursor", "last")
end

function M.first_column()
  Command.new("move_cursor", "first_column")
end

function M.last_column()
  Command.new("move_cursor", "last_column")
end

function M.next_column()
  Command.new("move_cursor", "next_column")
end

function M.previous_column()
  Command.new("move_cursor", "previous_column")
end

function M.side_next()
  Command.new("move_cursor", "side_next")
end

function M.side_previous()
  Command.new("move_cursor", "side_previous")
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
