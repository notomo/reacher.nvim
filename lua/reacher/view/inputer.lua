local windowlib = require("reacher/lib/window")

local M = {}

local Inputer = {}
Inputer.__index = Inputer
M.Inputer = Inputer

function Inputer.open(callback)
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
  vim.bo[bufnr].bufhidden = "wipe"
  vim.api.nvim_buf_set_name(bufnr, "reacher://REACHER")
  vim.bo[bufnr].filetype = "reacher"
  vim.wo[window_id].winhighlight = "Normal:Normal,SignColumn:Normal"
  vim.wo[window_id].signcolumn = "yes:1"

  local on_leave = ("autocmd WinClosed,WinLeave,TabLeave,BufLeave,InsertLeave <buffer=%s> ++once lua require 'reacher/command'.close(%s)"):format(bufnr, window_id)
  vim.api.nvim_command(on_leave)

  vim.api.nvim_buf_attach(bufnr, false, {
    on_lines = function()
      local input_line = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)[1]
      callback(input_line)
    end,
  })
  vim.api.nvim_command("startinsert")

  local tbl = {window_id = window_id}
  return setmetatable(tbl, Inputer)
end

function Inputer.close(self)
  windowlib.close(self.window_id)
  vim.api.nvim_command("stopinsert")
end

return M
