local Command = require("reacher.command").Command

local reacher = {}

---Start reacher mode.
---@param opts table: default {input = "", first_row = nil, last_row = nil}
function reacher.start(opts)
  Command.new("start_one", opts)
end

---Start reacher mode for the multiple windows.
---@param opts table: default {input = ""}
function reacher.start_multiple(opts)
  Command.new("start_multiple", opts)
end

---Execute again the previous call: start() or start_multiple().
---@param opts table: default {input = "", first_row = nil, last_row = nil}
function reacher.again(opts)
  Command.new("again", opts)
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
function reacher.side_first()
  Command.new("move_cursor", "side_first")
end

---Move cursor to the target in the last column.
function reacher.side_last()
  Command.new("move_cursor", "side_last")
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
