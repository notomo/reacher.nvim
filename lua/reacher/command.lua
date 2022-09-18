local ShowError = require("reacher.vendor.misclib.error_handler").for_show_error()
local View = require("reacher.view").View
local Matcher = require("reacher.core.matcher")
local messagelib = require("reacher.lib.message")
local vim = vim

local last_call = nil

function ShowError.start_one(raw_opts)
  local msg = messagelib.validate({ opts = { raw_opts, "table", true } })
  if msg then
    return msg
  end

  local old = View.current()
  if old then
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

function ShowError.start_multiple(raw_opts)
  local msg = messagelib.validate({ opts = { raw_opts, "table", true } })
  if msg then
    return msg
  end

  local old = View.current()
  if old then
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

function ShowError.again(extend_opts)
  local msg = messagelib.validate({ opts = { extend_opts, "table", true } })
  if msg then
    return msg
  end

  local old = View.current()
  if old then
    old:close()
  end

  if not last_call then
    return ShowError.start_one(extend_opts)
  end

  return last_call(extend_opts)
end

function ShowError.move_cursor(action_name)
  vim.validate({ action_name = { action_name, "string" } })

  local view, err = View.current()
  if err then
    return err
  end

  view:move_cursor(action_name)
end

function ShowError.finish()
  local view, err = View.current()
  if err then
    return err
  end

  local row, column = view:finish()
  if row then
    messagelib.info(("jumped to (%d, %d)"):format(row, column))
  end
end

function ShowError.recall_history(offset)
  vim.validate({ offset = { offset, "number" } })
  local view, err = View.current()
  if err then
    return err
  end
  view:recall_history(offset)
end

function ShowError.cancel()
  local view, err = View.current()
  if err then
    return
  end
  view:cancel()
  messagelib.info("canceled")
end

function ShowError.close(id)
  vim.validate({ id = { id, "number" } })
  local view = View.get(id)
  if not view then
    return
  end
  view:cancel()
end

return ShowError:methods()
