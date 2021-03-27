local Command = require("reacher.command").Command

local reacher = {}

---Start reacher mode.
---@param opts table: default {input = ""}
function reacher.start(opts)
  Command.new("start", opts)
end

---Move cursor to the first target.
function reacher.first()
  Command.new("move_cursor", "first")
end

---Move cursor to the next target.
function reacher.next()
  Command.new("move_cursor", "next")
end

---Move cursor to the previous target.
function reacher.previous()
  Command.new("move_cursor", "previous")
end

---Move cursor to the last target.
function reacher.last()
  Command.new("move_cursor", "last")
end

---Move cursor to the target in the first column.
function reacher.first_column()
  Command.new("move_cursor", "first_column")
end

---Move cursor to the target in the last column.
function reacher.last_column()
  Command.new("move_cursor", "last_column")
end

---Move cursor to the target in the side next.
function reacher.side_next()
  Command.new("move_cursor", "side_next")
end

---Move cursor to the target in the side previous.
function reacher.side_previous()
  Command.new("move_cursor", "side_previous")
end

---Recall the forward search history.
function reacher.forward_history()
  Command.new("recall_history", 1)
end

---Recall the backword search history.
function reacher.backward_history()
  Command.new("recall_history", -1)
end

---Finish reacher mode and jump to the current target.
function reacher.finish()
  Command.new("finish")
end

---Quit reacher mode.
function reacher.cancel()
  Command.new("cancel")
end

return reacher
