local View = require("reacher.view")
local Matcher = require("reacher.core.matcher")
local messagelib = require("reacher.lib.message")
local vim = vim

local M = {}

local last_call = nil

function M.start_one(raw_opts)
  local msg = messagelib.validate({ opts = { raw_opts, "table", true } })
  if msg then
    return msg
  end

  local old = View.current()
  if type(old) == "table" then
    old:close()
  end

  local opts = vim.tbl_deep_extend("force", { matcher_opts = { name = "regex" } }, raw_opts or {})
  local matcher, err = Matcher.new(opts.matcher_opts.name)
  if err then
    return err
  end

  local call = function(extend_opts)
    return View.open_one(matcher, vim.tbl_deep_extend("force", opts, extend_opts or {}))
  end
  last_call = call

  return call()
end

function M.start_multiple(raw_opts)
  local msg = messagelib.validate({ opts = { raw_opts, "table", true } })
  if msg then
    return msg
  end

  local old = View.current()
  if type(old) == "table" then
    old:close()
  end

  local opts = vim.tbl_deep_extend("force", { matcher_opts = { name = "regex" } }, raw_opts or {})
  local matcher, err = Matcher.new(opts.matcher_opts.name)
  if err then
    return err
  end

  local call = function(extend_opts)
    return View.open_multiple(matcher, vim.tbl_deep_extend("force", opts, extend_opts or {}))
  end
  last_call = call

  return call()
end

function M.again(extend_opts)
  local msg = messagelib.validate({ opts = { extend_opts, "table", true } })
  if msg then
    return msg
  end

  local old = View.current()
  if type(old) == "table" then
    old:close()
  end

  if not last_call then
    return M.start_one(extend_opts)
  end

  return last_call(extend_opts)
end

function M.move_cursor(action_name)
  vim.validate({ action_name = { action_name, "string" } })

  local view = View.current()
  if type(view) == "string" then
    local err = view
    require("reacher.lib.message").error(err)
    return
  end

  view:move_cursor(action_name)
end

function M.finish()
  local view = View.current()
  if type(view) == "string" then
    local err = view
    require("reacher.lib.message").error(err)
    return
  end

  local row, column = view:finish()
  if row then
    messagelib.info(("jumped to (%d, %d)"):format(row, column))
  end
end

function M.recall_history(offset)
  vim.validate({ offset = { offset, "number" } })
  local view, err = View.current()
  if err then
    require("reacher.lib.message").error(err)
  end
  view:recall_history(offset)
end

function M.cancel()
  local view = View.current()
  if type(view) == "string" then
    local err = view
    require("reacher.lib.message").error(err)
    return
  end

  view:cancel()
  messagelib.info("canceled")
end

function M.close(id)
  vim.validate({ id = { id, "number" } })
  local view = View.get(id)
  if not view then
    return
  end
  view:cancel()
end

return M
