local Position = require("reacher.model.position").Position

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

  local cursor = Position.cursor(id)
  local saved = vim.fn.winsaveview()
  vim.api.nvim_win_set_cursor(id, {cursor.row, 0})
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

  local start_row = first_row
  local count = vim.api.nvim_buf_line_count(bufnr)
  local folds = {}
  while start_row <= count do
    local end_row = vim.fn.foldclosedend(start_row)
    if end_row ~= -1 then
      table.insert(folds, {start_row, end_row})
      start_row = end_row + 1
    else
      start_row = start_row + 1
    end
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, first_row - 1, last_row, true)
  for _, fold in ipairs(folds) do
    for i = fold[1] - first_row + 1, fold[2] - first_row + 1, 1 do
      lines[i] = ""
    end
  end
  if not options.wrap then
    lines = vim.tbl_map(function(line)
      return line:sub(first_column, last_column)
    end, lines)
  end

  local offset = Position.new(first_row - 1, first_column - 1)
  local tbl = {
    id = id,
    lines = lines,
    offset = offset,
    cursor = Position.new(cursor.row - offset.row, cursor.column - offset.column),
    _row = row,
    _column = column,
    _width = width,
    _height = height,
    _options = options,
    _folds = folds,
  }
  return setmetatable(tbl, Origin)
end

function Origin.copy_to_floating_win(self, bufnr)
  local window_id = vim.api.nvim_open_win(bufnr, true, {
    width = self._width,
    height = self._height,
    relative = "win",
    row = self._row,
    col = self._column,
    bufpos = {self.offset.row, 0},
    external = false,
    style = "minimal",
    focusable = false,
  })

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, self.lines)
  for _, range in ipairs(self._folds) do
    vim.cmd(("%d,%dfold"):format(range[1], range[2]))
  end

  vim.bo[bufnr].textwidth = self._options.textwidth
  vim.wo[window_id].list = self._options.list
  vim.wo[window_id].wrap = self._options.wrap
  vim.wo[window_id].foldenable = #self._folds > 0

  local listchars = table.concat(vim.fn.split(self._options.listchars, ",precedes:."))
  listchars = table.concat(vim.split(listchars, ",extends:.", true))
  vim.wo[window_id].listchars = listchars

  vim.api.nvim_set_current_win(self.id)

  return window_id
end

return M
