local Position = require("reacher.model.position").Position
local Folds = require("reacher.model.fold").Folds
local Fillers = require("reacher.model.diff").Fillers
local Conceals = require("reacher.model.conceal").Conceals
local Lines = require("reacher.model.line").Lines
local windowlib = require("reacher.lib.window")
local vim = vim

local M = {}

local Origin = {}
Origin.__index = Origin
M.Origin = Origin

function Origin.new(bufnr, row_range)
  local first_row = row_range:first()
  local last_row = row_range:last()
  local height = last_row - first_row + 1
  if height <= 0 then
    return nil, "no range"
  end

  local options = {
    list = vim.wo.list,
    wrap = vim.wo.wrap,
    listchars = vim.o.listchars,
    tabstop = vim.bo.tabstop,
    softtabstop = vim.bo.softtabstop,
    breakindent = vim.wo.breakindent,
    breakindentopt = vim.wo.breakindentopt,
    linebreak = vim.wo.linebreak,
  }

  local window_id = vim.api.nvim_get_current_win()

  local cursor = Position.cursor(window_id)
  local saved = vim.fn.winsaveview()
  vim.api.nvim_win_set_cursor(window_id, {cursor.row, 0})
  local number_sign_width = vim.fn.wincol()
  vim.fn.winrestview(saved)

  local width = vim.api.nvim_win_get_width(window_id) - number_sign_width + 1

  local row = 0
  local column = 0
  if saved.leftcol >= number_sign_width then
    column = number_sign_width + 1
  elseif saved.leftcol >= 1 then
    column = saved.leftcol
  end

  local config = vim.api.nvim_win_get_config(window_id)
  if config.relative ~= "" then
    row = row + config.row[false]
    column = column + config.col[false]
  end

  local first_column = saved.leftcol + 1
  local last_column = saved.leftcol + width

  local fillers = Fillers.new(first_row, last_row)
  local folds = Folds.new(first_row, last_row, fillers)
  local conceals = Conceals.new(bufnr, first_row, last_row, fillers)
  local lines = Lines.new(first_column, last_column, conceals, folds, fillers, options.wrap)

  local offset = lines:offset(first_row)
  local cursor_pos = Position.new(cursor.row + fillers:offset(cursor.row) - offset.row, cursor.column - offset.column - conceals:offset_from_origin(cursor.row, cursor.column + 1))
  local tbl = {
    window_id = window_id,
    lines = lines,
    cursor = cursor_pos,
    _offset = offset,
    _row = row,
    _column = column,
    _width = width,
    _height = height,
    _options = options,
    _conceals = conceals,
    _folds = folds,
    _fillers = fillers,
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
    bufpos = {self._offset.row, 0},
    external = false,
    style = "minimal",
    focusable = false,
  })

  self.lines:copy_to(bufnr)

  vim.bo[bufnr].tabstop = self._options.tabstop
  vim.bo[bufnr].softtabstop = self._options.softtabstop
  vim.wo[window_id].list = self._options.list
  vim.wo[window_id].wrap = self._options.wrap
  vim.wo[window_id].breakindent = self._options.breakindent
  vim.wo[window_id].breakindentopt = self._options.breakindentopt
  vim.wo[window_id].linebreak = self._options.linebreak
  vim.wo[window_id].foldenable = self._folds:exists()

  local listchars = vim.tbl_filter(function(v)
    return not vim.startswith(v, "extends:") and not vim.startswith(v, "precedes:")
  end, vim.fn.split(self._options.listchars, ",", true))
  vim.wo[window_id].listchars = table.concat(listchars, ",")

  vim.api.nvim_set_current_win(self.window_id)

  return window_id
end

function Origin.enter(self)
  windowlib.enter(self.window_id)
end

function Origin.jump(self, row, column, mode)
  local origin_row = row + self._offset.row - self._fillers:offset_from_origin(row)

  local insert_offset = 1 -- for stopinsert
  if mode == "n" then
    insert_offset = 0
  end
  column = column + self._offset.column + insert_offset
  local origin_column = column + self._conceals:offset(origin_row, column)

  windowlib.jump(self.window_id, origin_row, origin_column)
  return origin_row, origin_column
end

return M
