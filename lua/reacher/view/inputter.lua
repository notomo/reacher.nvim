local highlightlib = require("reacher.lib.highlight")
local windowlib = require("reacher.lib.window")
local wraplib = require("reacher.lib.wrap")
local vim = vim

local M = {}

local Inputter = {}
Inputter.__index = Inputter
M.Inputter = Inputter

function Inputter.open(callback, default_input)
  vim.validate({callback = {callback, "function"}, default_input = {default_input, "string", true}})
  default_input = default_input or ""

  local bufnr = vim.api.nvim_create_buf(false, true)
  local window_id = vim.api.nvim_open_win(bufnr, true, {
    width = vim.o.columns,
    height = 1,
    relative = "editor",
    row = 10000,
    col = 0,
    external = false,
    style = "minimal",
  })
  local name = "reacher://REACHER"
  local old = vim.fn.bufnr(("^%s$"):format(name))
  if old ~= -1 then
    vim.api.nvim_buf_delete(old, {force = true})
  end
  vim.api.nvim_buf_set_name(bufnr, "reacher://REACHER")
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].filetype = "reacher"
  vim.wo[window_id].winhighlight = "Normal:Normal,SignColumn:Normal"
  vim.wo[window_id].signcolumn = "yes:1"

  local on_leave = ("autocmd WinClosed,WinLeave,TabLeave,BufLeave,BufWipeout <buffer=%s> ++once lua require('reacher.command').Command.new('close', %s, true)"):format(bufnr, window_id)
  vim.cmd(on_leave)

  local on_insert_leave = ("autocmd InsertLeave <buffer=%s> lua require('reacher.view.inputter').on_insert_leave()"):format(bufnr)
  vim.cmd(on_insert_leave)

  local on_insert_enter = ("autocmd InsertEnter <buffer=%s> lua require('reacher.view.inputter').on_insert_enter()"):format(bufnr)
  vim.cmd(on_insert_enter)

  vim.api.nvim_buf_attach(bufnr, false, {
    on_lines = wraplib.traceback(function()
      local input_line = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)[1]
      callback(input_line)

      if vim.api.nvim_buf_line_count(bufnr) == 1 then
        return
      end
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(bufnr, 1, -1, false, {})
      end)
    end),
  })
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, {vim.split(default_input, "\n", true)[1]})
  vim.cmd("startinsert!")

  local tbl = {window_id = window_id, _bufnr = bufnr}
  return setmetatable(tbl, Inputter)
end

function Inputter.close(self, is_cancel)
  vim.validate({is_cancel = {is_cancel, "boolean", true}})

  -- NOTICE: bacause sometimes the buffer is not deleted.
  vim.api.nvim_buf_delete(self._bufnr, {force = true})
  windowlib.close(self.window_id)

  local insert_mode = vim.api.nvim_get_mode().mode == "i"
  if not insert_mode then
    return
  end
  vim.cmd("stopinsert")

  if is_cancel then
    local row, column = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_win_set_cursor(0, {row, column + 1})
  end
end

function M.on_insert_leave()
  highlightlib.link("ReacherCurrentMatch", "ReacherCurrentMatchNormal", true)
end

function M.on_insert_enter()
  highlightlib.link("ReacherCurrentMatch", "ReacherCurrentMatchInsert", true)
end

return M
