local M = {}

local root, err = require("reacher/lib/path").find_root("reacher/*.lua")
if err ~= nil then
  error(err)
end
M.root = root

M.command = function(cmd)
  vim.api.nvim_command(cmd)
end

M.before_each = function()
  require("reacher/lib/module").cleanup()
  M.command("filetype on")
  M.command("syntax enable")
end

M.after_each = function()
  M.command("tabedit")
  M.command("tabonly!")
  M.command("silent! %bwipeout!")
  M.command("filetype off")
  M.command("syntax off")
  print(" ")
end

M.set_lines = function(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

M.input = function(text)
  vim.api.nvim_put({text}, "c", true, true)
end

M.sync_input = function(text)
  local finished = false
  require("reacher/view")._after = function()
    finished = true
  end

  M.input(text)

  local ok = vim.wait(1000, function()
    return finished
  end, 10)
  if not ok then
    assert(false, "wait timeout")
  end
end

local vassert = require("vusted.assert")
local asserts = vassert.asserts

asserts.create("window_count"):register_eq(function()
  return vim.fn.tabpagewinnr(vim.fn.tabpagenr(), "$")
end)

asserts.create("current_line"):register_eq(function()
  return vim.fn.getline(".")
end)

asserts.create("cursor_word"):register_eq(function()
  return vim.fn.expand("<cword>")
end)

return M
