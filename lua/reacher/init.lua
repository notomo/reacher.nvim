local reacher = {}

---Start reacher mode.
---@param opts table|nil: default {input = "", first_row = nil, last_row = nil}
function reacher.start(opts)
  local err = require("reacher.command").start_one(opts)
  if err then
    require("reacher.lib.message").error(err)
  end
end

---Start reacher mode for the multiple windows.
---@param opts table|nil: default {input = ""}
function reacher.start_multiple(opts)
  local err = require("reacher.command").start_multiple(opts)
  if err then
    require("reacher.lib.message").error(err)
  end
end

---Execute again the previous call: start() or start_multiple().
---@param opts table|nil: default {input = "", first_row = nil, last_row = nil}
function reacher.again(opts)
  local err = require("reacher.command").again(opts)
  if err then
    require("reacher.lib.message").error(err)
  end
end

---Move cursor to the first target.
function reacher.first()
  require("reacher.command").move_cursor("first")
end

---Move cursor to the next target.
function reacher.next()
  require("reacher.command").move_cursor("next")
end

---Move cursor to the previous target.
function reacher.previous()
  require("reacher.command").move_cursor("previous")
end

---Move cursor to the last target.
function reacher.last()
  require("reacher.command").move_cursor("last")
end

---Move cursor to the target in the first column.
function reacher.side_first()
  require("reacher.command").move_cursor("side_first")
end

---Move cursor to the target in the last column.
function reacher.side_last()
  require("reacher.command").move_cursor("side_last")
end

---Move cursor to the target in the side next.
function reacher.side_next()
  require("reacher.command").move_cursor("side_next")
end

---Move cursor to the target in the side previous.
function reacher.side_previous()
  require("reacher.command").move_cursor("side_previous")
end

---Recall the forward search history.
function reacher.forward_history()
  require("reacher.command").recall_history(1)
end

---Recall the backword search history.
function reacher.backward_history()
  require("reacher.command").recall_history(-1)
end

---Finish reacher mode and jump to the current target.
function reacher.finish()
  require("reacher.command").finish()
end

---Quit reacher mode.
function reacher.cancel()
  require("reacher.command").cancel()
end

return reacher
