local repository = require("reacher/lib/repository")
local modulelib = require("reacher/lib/module")
local View = require("reacher/view").View

local M = {}

local Command = {}

function Command.start()
  local source_name = "word" -- TODO
  local source = modulelib.find_source(source_name)
  if source == nil then
    return "[reacher] not found source: " .. source_name
  end
  local view = View.open(source)
  repository.set(view.id, view)
end

function Command.next()
  -- TODO
end

function Command.prev()
  -- TODO
end

function Command.finish()
  -- TODO
end

M.close = function(id)
  local view = repository.get(id)
  if view == nil then
    return
  end
  view:close()
  repository.delete(id)
end

M.main = function(...)
  local cmd_name = ({...})[1] or "start"
  local cmd = Command[cmd_name]
  if cmd == nil then
    return vim.api.nvim_err_write("[reacher] not found command: " .. cmd_name .. "\n")
  end

  local _, err = xpcall(cmd, debug.traceback)
  if err ~= nil then
    return vim.api.nvim_err_write(err .. "\n")
  end
end

return M
