local M = {}

local root, err = require("reacher.lib.path").find_root("reacher/*.lua")
if err ~= nil then
  error(err)
end
M.root = root

M.before_each = function()
  require("reacher.lib.module").cleanup()
  vim.cmd("filetype on")
  vim.cmd("syntax enable")
end

M.after_each = function()
  vim.cmd("tabedit")
  vim.cmd("tabonly!")
  vim.cmd("silent! %bwipeout!")
  vim.cmd("filetype off")
  vim.cmd("syntax off")
  print(" ")
end

M.set_lines = function(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

M.input = function(str)
  local texts = vim.split(str, "\n", true)
  vim.api.nvim_put(texts, "", false, true)
end

M.search = function(pattern)
  local result = vim.fn.search(pattern)
  if result == 0 then
    local info = debug.getinfo(2)
    local pos = ("%s:%d"):format(info.source, info.currentline)
    local lines = table.concat(vim.fn.getbufline("%", 1, "$"), "\n")
    local msg = ("on %s: `%s` not found in buffer:\n%s"):format(pos, pattern, lines)
    assert(false, msg)
  end
  return result
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

asserts.create("error_message"):register(function(self)
  return function(_, args)
    local expected = args[1]
    local f = args[2]
    local ok, actual = pcall(f)
    if ok then
      self:set_positive("should be error")
      self:set_negative("should be error")
      return false
    end
    self:set_positive(("error message should end with '%s', but actual: '%s'"):format(expected, actual))
    self:set_negative(("error message should not end with '%s', but actual: '%s'"):format(expected, actual))
    return vim.endswith(actual, expected)
  end
end)

asserts.create("exists_message"):register(function(self)
  return function(_, args)
    local expected = args[1]
    self:set_positive(("`%s` not found message"):format(expected))
    self:set_negative(("`%s` found message"):format(expected))
    local messages = vim.split(vim.api.nvim_exec("messages", true), "\n")
    for _, msg in ipairs(messages) do
      if msg:match(expected) then
        return true
      end
    end
    return false
  end
end)

return M
