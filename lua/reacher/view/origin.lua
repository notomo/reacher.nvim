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

function Origin.new(old_mode, bufnr, row_range)
  local first_row = row_range:first()
  local last_row = row_range:last()
  local win_first_row, height = M._view_position(first_row, last_row, row_range.given_range)
  if height <= 0 or last_row - first_row < 0 then
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
  local number_sign_width = vim.fn.wincol() - 1
  vim.fn.winrestview(saved)

  local width = vim.api.nvim_win_get_width(window_id) - number_sign_width

  local row = win_first_row
  local column = 0
  if saved.leftcol >= number_sign_width + 2 then
    column = number_sign_width + 2
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
  local conceals = Conceals.new(bufnr, first_row, last_row, fillers, old_mode)
  local lines = Lines.new(first_column, last_column, conceals, folds, fillers, options.wrap)

  local row_offset = first_row - 1
  local cursor_row = cursor.row + fillers:offset(cursor.row) - row_offset
  local corsor_column = cursor.column - lines:column_offset(cursor_row) - conceals:offset_from_origin(cursor.row, cursor.column + 1)
  local cursor_pos = Position.new(cursor_row, corsor_column)
  local tbl = {
    window_id = window_id,
    lines = lines,
    cursor = cursor_pos,
    _row = row,
    _row_offset = row_offset,
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
  local bufpos = {1, 0}
  local row = self._row
  local first_row = vim.fn.line("w0")
  -- HACK: ?
  if first_row <= 2 then
    bufpos = {first_row - 1, 0}
    row = row - 1
  end
  local window_id = vim.api.nvim_open_win(bufnr, true, {
    width = self._width,
    height = self._height,
    relative = "win",
    row = row,
    col = self._column,
    bufpos = bufpos,
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
  local origin_row = row + self._row_offset - self._fillers:offset_from_origin(row)

  local insert_offset = 1 -- for stopinsert
  if mode == "n" then
    insert_offset = 0
  end
  column = column + self.lines:column_offset(row) + insert_offset
  local origin_column = column + self._conceals:offset(origin_row, column)

  windowlib.jump(self.window_id, origin_row, origin_column)
  return origin_row, origin_column
end

-- HACK
function M._view_position(first_row, last_row, given_range)
  if not given_range then
    return 1, vim.api.nvim_win_get_height(0)
  end

  local saved = vim.fn.winsaveview()

  local scrolloff = vim.api.nvim_exec("silent! echo &scrolloff", true)
  vim.cmd("silent! setlocal scrolloff=0")

  vim.cmd(("silent! noautocmd %d"):format(first_row))
  local win_first_row = vim.fn.winline()
  vim.fn.winrestview(saved)

  vim.cmd(("silent! noautocmd %d"):format(last_row))
  local win_last_row = vim.fn.winline()
  vim.cmd("silent! setlocal scrolloff=" .. tostring(scrolloff))
  vim.fn.winrestview(saved)

  return win_first_row, win_last_row - win_first_row + 1
end

return M
