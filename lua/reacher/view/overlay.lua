local windowlib = require("reacher/lib/window")

local M = {}

local Overlay = {}
Overlay.__index = Overlay
M.Overlay = Overlay

function Overlay.open(source, source_bufnr)
  local first_row = vim.fn.line("w0")
  local last_row = vim.fn.line("w$")
  local lines = vim.api.nvim_buf_get_lines(source_bufnr, first_row - 1, last_row, true)

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

  local row = 0
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
    bufpos = {first_row - 1, 0},
    external = false,
    style = "minimal",
  })
  vim.fn.winrestview({
    col = view.col,
    coladd = view.coladd,
    leftcol = view.leftcol,
    skipcol = view.skipcol,
  })

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, lines)
  vim.api.nvim_win_set_cursor(window_id, {cursor_row - (first_row - 1), cursor_column})
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  vim.api.nvim_buf_set_option(bufnr, "textwidth", original.textwidth)

  vim.api.nvim_win_set_option(window_id, "winhighlight", "Normal:ReacherBackground")
  vim.api.nvim_win_set_option(window_id, "list", original.list)
  vim.api.nvim_win_set_option(window_id, "wrap", original.wrap)

  local listchars = table.concat(vim.fn.split(original.listchars, ",precedes:."))
  listchars = table.concat(vim.split(listchars, ",extends:.", true))
  vim.api.nvim_win_set_option(window_id, "listchars", listchars)

  local positions = source.collect(source_bufnr, first_row, last_row)

  local cursor = vim.api.nvim_win_get_cursor(origin_window_id)
  local tbl = {
    window_id = window_id,
    _origin_window_id = origin_window_id,
    _bufnr = bufnr,
    _row_offset = first_row - 1,
    _all_positions = positions,
    _positions = {},
    _cursor = {row = cursor[1], column = cursor[2]},
  }
  local overlay = setmetatable(tbl, Overlay)

  overlay:_set_backgroud_hl()
  overlay:update("")

  return overlay
end

function Overlay._set_backgroud_hl(self)
  local bg_hl_group = "Normal"
  if vim.api.nvim_win_get_config(self._origin_window_id).relative ~= "" then
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

local ns = vim.api.nvim_create_namespace("reacher")
local current_ns = vim.api.nvim_create_namespace("reacher-current")

function Overlay.update(self, input_line)
  local positions = {}
  for _, pos in ipairs(self._all_positions) do
    if vim.startswith(pos.line, input_line) then
      table.insert(positions, pos)
    end
  end
  self._positions = positions

  if #positions == 1 then
    self:finish(positions[1])
    return
  elseif #positions == 0 then
    self:close()
    return
  end

  vim.api.nvim_buf_clear_namespace(self._bufnr, ns, 0, -1)
  vim.api.nvim_buf_clear_namespace(self._bufnr, current_ns, 0, -1)

  self._index = 1
  local tmp_pos = positions[self._index]
  local hl_pos = {
    row = tmp_pos.row,
    column = tmp_pos.column,
    y_diff = math.abs(self._cursor.row - tmp_pos.row),
    x_diff = math.abs(self._cursor.column - tmp_pos.column),
  }
  for i, pos in ipairs(positions) do
    local y_diff = math.abs(self._cursor.row - pos.row)
    local x_diff = math.abs(self._cursor.column - pos.column)
    if y_diff < hl_pos.y_diff or (y_diff == hl_pos.y_diff and x_diff < hl_pos.x_diff) then
      hl_pos = {row = pos.row, column = pos.column, y_diff = y_diff, x_diff = x_diff}
      self._index = i
    end
    vim.api.nvim_buf_add_highlight(self._bufnr, ns, "String", pos.row - self._row_offset - 1, pos.column, pos.column + 1)
  end
  vim.api.nvim_buf_add_highlight(self._bufnr, current_ns, "Todo", hl_pos.row - self._row_offset - 1, hl_pos.column, hl_pos.column + 1)

  self._hl_pos = hl_pos
end

function Overlay.close(self)
  windowlib.close(self.window_id)
  windowlib.enter(self._origin_window_id)
  vim.api.nvim_command("stopinsert")
end

function Overlay.finish(self, pos)
  pos = pos or self._hl_pos
  vim.api.nvim_set_current_win(self._origin_window_id)
  vim.api.nvim_win_set_cursor(self._origin_window_id, {pos.row, pos.column + 1})
end

function Overlay.next(self)
  self._index = (self._index % #self._positions) + 1
  self._hl_pos = self._positions[self._index]
  vim.api.nvim_buf_clear_namespace(self._bufnr, current_ns, 0, -1)
  vim.api.nvim_buf_add_highlight(self._bufnr, current_ns, "Todo", self._hl_pos.row - self._row_offset - 1, self._hl_pos.column, self._hl_pos.column + 1)
end

function Overlay.prev(self)
  self._index = ((self._index - 1) % #self._positions - 1) % #self._positions + 1
  self._hl_pos = self._positions[self._index]
  vim.api.nvim_buf_clear_namespace(self._bufnr, current_ns, 0, -1)
  vim.api.nvim_buf_add_highlight(self._bufnr, current_ns, "Todo", self._hl_pos.row - self._row_offset - 1, self._hl_pos.column, self._hl_pos.column + 1)
end

return M
