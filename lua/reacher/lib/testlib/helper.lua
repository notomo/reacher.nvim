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

M.input_key = function(key)
  M.command("normal " .. key)
end

M.jump_before = function()
  M.input_key("``")
end

M.set_lines = function(lines)
  vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.split(lines, "\n"))
end

M.cursor = function()
  return {vim.fn.line("."), vim.fn.col(".")}
end

local vassert = require("vusted.assert")
local asserts = vassert.asserts

asserts.create("window_count"):register_eq(function()
  return vim.fn.tabpagewinnr(vim.fn.tabpagenr(), "$")
end)

asserts.create("current_line"):register_eq(function()
  return vim.fn.getline(".")
end)

asserts.create("line"):register_eq(function(number)
  return vim.fn.getline(number)
end)

asserts.create("current_char"):register_eq(function()
  local col = vim.fn.col(".")
  return vim.fn.getline("."):sub(col, col)
end)

asserts.create("cursor"):register_same(function()
  return M.cursor()
end)

asserts.create("column"):register_eq(function()
  return vim.fn.col(".")
end)

asserts.create("window_width"):register_eq(function()
  return vim.api.nvim_win_get_width(0)
end)

asserts.create("window_height"):register_eq(function()
  return vim.api.nvim_win_get_height(0)
end)

asserts.create("window_relative_row"):register_eq(function()
  return vim.fn.winline()
end)

asserts.create("window_col"):register_eq(function()
  return vim.fn.win_screenpos(0)[2]
end)

return M
