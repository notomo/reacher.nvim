local M = {}

local Origin = {}
Origin.__index = Origin
M.Origin = Origin

function Origin.new(bufnr)
  local options = {
    list = vim.wo.list,
    wrap = vim.wo.wrap,
    textwidth = vim.bo.textwidth,
    listchars = vim.o.listchars,
  }

  local id = vim.api.nvim_get_current_win()

  local cursor_row, cursor_column = unpack(vim.api.nvim_win_get_cursor(id))
  local saved = vim.fn.winsaveview()
  vim.api.nvim_win_set_cursor(id, {cursor_row, 0})
  local number_sign_width = vim.fn.wincol()
  vim.fn.winrestview(saved)

  local width = vim.api.nvim_win_get_width(id) - number_sign_width + 1
  local height = vim.api.nvim_win_get_height(id)

  local row = 0
  local column = 0
  if saved.leftcol >= number_sign_width then
    column = number_sign_width + 1
  elseif saved.leftcol >= 1 then
    column = saved.leftcol
  end

  local config = vim.api.nvim_win_get_config(id)
  if config.relative ~= "" then
    row = row + config.row[false]
    column = column + config.col[false]
  end

  local first_row = vim.fn.line("w0")
  local last_row = vim.fn.line("w$")
  local first_column = saved.leftcol + 1
  local last_column = saved.leftcol + width

  local lines = vim.tbl_map(function(line)
    return line:sub(first_column, last_column)
  end, vim.api.nvim_buf_get_lines(bufnr, first_row - 1, last_row, true))

  local tbl = {
    id = id,
    lines = lines,
    row_offset = first_row - 1,
    column_offset = first_column - 1,
    _first_row = first_row,
    _cursor = {row = cursor_row, column = cursor_column},
    _row = row,
    _column = column,
    _width = width,
    _height = height,
    _options = options,
  }
  return setmetatable(tbl, Origin)
end

function Origin.copy_to_floating_win(self, bufnr)
  local window_id = vim.api.nvim_open_win(bufnr, false, {
    width = self._width,
    height = self._height,
    relative = "win",
    row = self._row,
    col = self._column,
    bufpos = {self._first_row - 1, 0},
    external = false,
    style = "minimal",
    focusable = false,
  })

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, self.lines)
  vim.api.nvim_buf_set_option(bufnr, "textwidth", self._options.textwidth)
  vim.api.nvim_win_set_cursor(window_id, {
    self._cursor.row - self.row_offset,
    self._cursor.column - self.column_offset,
  })
  vim.api.nvim_win_set_option(window_id, "list", self._options.list)
  vim.api.nvim_win_set_option(window_id, "wrap", self._options.wrap)

  local listchars = table.concat(vim.fn.split(self._options.listchars, ",precedes:."))
  listchars = table.concat(vim.split(listchars, ",extends:.", true))
  vim.api.nvim_win_set_option(window_id, "listchars", listchars)

  return window_id
end

return M
