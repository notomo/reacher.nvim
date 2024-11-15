local View = require("reacher.view")
local Matcher = require("reacher.core.matcher")
local vim = vim

local M = {}

local last_call = nil

function M.start_one(raw_opts)
  local msg = require("reacher.lib.message").validate({ opts = { raw_opts, "table", true } })
  if msg then
    return msg
  end

  local old = View.current()
  if type(old) == "table" then
    old:close()
  end

  local opts = vim.tbl_deep_extend("force", { matcher_opts = { name = "regex" } }, raw_opts or {})
  local matcher = Matcher.new(opts.matcher_opts.name)
  if type(matcher) == "string" then
    local err = matcher
    return err
  end

  local call = function(extend_opts)
    return View.open_one(matcher, vim.tbl_deep_extend("force", opts, extend_opts or {}))
  end
  last_call = call

  return call()
end

function M.start_multiple(raw_opts)
  local msg = require("reacher.lib.message").validate({ opts = { raw_opts, "table", true } })
  if msg then
    return msg
  end

  local old = View.current()
  if type(old) == "table" then
    old:close()
  end

  local opts = vim.tbl_deep_extend("force", { matcher_opts = { name = "regex" } }, raw_opts or {})
  local matcher = Matcher.new(opts.matcher_opts.name)
  if type(matcher) == "string" then
    local err = matcher
    return err
  end

  local call = function(extend_opts)
    return View.open_multiple(matcher, vim.tbl_deep_extend("force", opts, extend_opts or {}))
  end
  last_call = call

  return call()
end

function M.again(extend_opts)
  local msg = require("reacher.lib.message").validate({ opts = { extend_opts, "table", true } })
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

--- @param action_name string
function M.move_cursor(action_name)
  local view = View.current()
  if type(view) == "string" then
    local err = view
    error("[reacher] " .. err, 0)
  end

  view:move_cursor(action_name)
end

function M.finish()
  local view = View.current()
  if type(view) == "string" then
    local err = view
    error("[reacher] " .. err, 0)
  end

  local row, column = view:finish()
  if row then
    vim.notify(("[reacher] jumped to (%d, %d)"):format(row, column))
  end
end

--- @param offset integer
function M.recall_history(offset)
  local view = View.current()
  if type(view) == "string" then
    local err = view
    error("[reacher] " .. err, 0)
  end
  view:recall_history(offset)
end

function M.cancel()
  local view = View.current()
  if type(view) == "string" then
    local err = view
    error("[reacher] " .. err, 0)
  end

  view:cancel()
  vim.notify("[reacher] canceled")
end

--- @param id integer
function M.close(id)
  local view = View.get(id)
  if not view then
    return
  end
  view:cancel()
end

return M
