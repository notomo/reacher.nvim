local windowlib = require("reacher/lib/window")
local repository = require("reacher/lib/repository")

local M = {}

local View = {}
View.__index = View
M.View = View

function View.new(source)
  local tbl = {_source = source}
  return setmetatable(tbl, View)
end

function View.open(self)
  local first_row = vim.fn.line("w0")
  local last_row = vim.fn.line("w$")
  local lines = vim.api.nvim_buf_get_lines(0, first_row - 1, last_row, true)

  local original = {
    list = vim.wo.list,
    wrap = vim.wo.wrap,
    textwidth = vim.bo.textwidth,
    listchars = vim.o.listchars,
  }

  local origin_window_id = vim.api.nvim_get_current_win()

  local cursor_row, cursor_column = unpack(vim.api.nvim_win_get_cursor(origin_window_id))
  local view = vim.fn.winsaveview()
  local restore_view = function()
    vim.fn.winrestview(view)
  end
  vim.api.nvim_win_set_cursor(origin_window_id, {cursor_row, 0})
  local number_sign_width = vim.fn.wincol()
  restore_view()

  local width = vim.api.nvim_win_get_width(origin_window_id) - number_sign_width + 1
  local height = vim.api.nvim_win_get_height(origin_window_id)

  local row = 1
  local column = 0
  local first_column = view.leftcol
  if first_column >= number_sign_width then
    column = number_sign_width + 1
  elseif first_column >= 1 then
    column = first_column
  end

  local win_config = vim.api.nvim_win_get_config(origin_window_id)
  if win_config.relative ~= "" then
    row = row + win_config.row[false]
    column = column + win_config.col[false]
  end

  local bufnr = vim.api.nvim_create_buf(false, true)
  local window_id = vim.api.nvim_open_win(bufnr, true, {
    width = width,
    height = height,
    relative = "win",
    row = row,
    col = column,
    bufpos = {0, 0},
    external = false,
    style = "minimal",
  })
  vim.fn.winrestview({
    col = view.col,
    coladd = view.coladd,
    leftcol = view.leftcol,
    skipcol = view.skipcol,
  })
  self._window_id = window_id

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
  vim.api.nvim_win_set_cursor(window_id, {cursor_row - (first_row - 1), cursor_column})
  self._set_backgroud_hl(origin_window_id)
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(bufnr, "textwidth", original.textwidth)

  vim.api.nvim_win_set_option(window_id, "winhighlight", "Normal:ReacherBackground")
  vim.api.nvim_win_set_option(window_id, "list", original.list)
  vim.api.nvim_win_set_option(window_id, "wrap", original.wrap)

  local listchars = table.concat(vim.fn.split(original.listchars, ",precedes:."))
  listchars = table.concat(vim.split(listchars, ",extends:.", true))
  vim.api.nvim_win_set_option(window_id, "listchars", listchars)

  local input_bufnr = vim.api.nvim_create_buf(false, true)
  local input_window = vim.api.nvim_open_win(input_bufnr, true, {
    width = vim.o.columns,
    height = 1,
    relative = "editor",
    row = 10000,
    col = 0,
    external = false,
    style = "minimal",
  })
  vim.api.nvim_command("startinsert")
  vim.api.nvim_buf_set_option(input_bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_name(input_bufnr, "reacher://reacher")
  vim.api.nvim_buf_attach(input_bufnr, false, {
    on_lines = function()
      local input_line = vim.api.nvim_buf_get_lines(input_bufnr, 0, -1, true)[1]
      self:update(input_line)
    end,
  })
  vim.api.nvim_win_set_option(input_window, "winhighlight", "Normal:Normal")
  self._input_window_id = input_window

  local on_leave = ("autocmd WinLeave,TabLeave,BufLeave <buffer=%s> ++once lua require 'reacher/view'.close(%s)"):format(bufnr, window_id)
  vim.api.nvim_command(on_leave)
  local on_input_leave = ("autocmd WinLeave,TabLeave,BufLeave <buffer=%s> ++once lua require 'reacher/view'.close(%s)"):format(input_bufnr, window_id)
  vim.api.nvim_command(on_input_leave)

  local on_close = ("autocmd WinClosed <buffer=%s> ++once lua require 'reacher/view'.close(%s)"):format(bufnr, window_id)
  vim.api.nvim_command(on_close)
  local on_input_close = ("autocmd WinClosed <buffer=%s> ++once lua require 'reacher/view'.close(%s)"):format(input_bufnr, window_id)
  vim.api.nvim_command(on_input_close)

  repository.set(window_id, self)
end

function View.update(self, input_line)
  -- TODO
end

function View.close(self)
  windowlib.close(self._window_id)
  windowlib.close(self._input_window_id)
end

M.close = function(window_id)
  local self = repository.get(window_id)
  if self == nil then
    return
  end
  self:close()
end

function View._set_backgroud_hl(origin_window_id)
  local bg_hl_group = "Normal"
  if vim.api.nvim_win_get_config(origin_window_id).relative ~= "" then
    bg_hl_group = "NormalFloat"
  end
  local guibg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(bg_hl_group)), "bg", "gui")
  if guibg == "" then
    guibg = "#334152"
  end

  local guifg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID("Comment")), "fg", "gui")
  if guifg == "" then
    guifg = "#8d9eb2"
  end

  local cmd = ("highlight! ReacherBackground guibg=%s guifg=%s"):format(guibg, guifg)
  vim.api.nvim_command(cmd)
end

return M
