local Position = require("reacher.core.position")
local Folds = require("reacher.core.fold")
local Fillers = require("reacher.core.diff_filler")
local Conceals = require("reacher.core.conceal").Conceals
local VirtLines = require("reacher.core.virt_lines")
local Lines = require("reacher.core.line").Lines
local windowlib = require("reacher.lib.window")
local vim = vim

local Origin = {}
Origin.__index = Origin

function Origin.new(window_id, old_mode, bufnr, row_range)
  if vim.wo[window_id].rightleft then
    return nil, "`rightleft` is not supported"
  end

  local first_row = row_range:first()
  local last_row = row_range:last()
  local height
  vim.api.nvim_win_call(window_id, function()
    height = Origin._view_height(first_row, last_row)
  end)
  if height <= 0 or last_row - first_row < 0 then
    return nil, "no range"
  end

  local options = {
    list = vim.wo[window_id].list,
    wrap = vim.wo[window_id].wrap,
    listchars = vim.o.listchars,
    tabstop = vim.bo[bufnr].tabstop,
    vartabstop = vim.bo[bufnr].vartabstop,
    softtabstop = vim.bo[bufnr].softtabstop,
    varsofttabstop = vim.bo[bufnr].varsofttabstop,
    breakindent = vim.wo[window_id].breakindent,
    breakindentopt = vim.wo[window_id].breakindentopt,
    linebreak = vim.wo[window_id].linebreak,
  }

  local cursor = Position.cursor(window_id)
  local saved
  vim.api.nvim_win_call(window_id, function()
    saved = vim.fn.winsaveview()
  end)
  local number_sign_width = vim.fn.getwininfo(window_id)[1].textoff

  local width = vim.api.nvim_win_get_width(window_id) - number_sign_width

  local column = 0
  if saved.leftcol > number_sign_width then
    column = number_sign_width + 2
  elseif saved.leftcol >= 1 then
    column = saved.leftcol
  end

  local first_column = saved.leftcol + 1
  local last_column = saved.leftcol + width

  local fillers = Fillers.new(window_id, first_row, last_row)
  local folds = Folds.new(window_id, first_row, last_row, fillers)
  local conceals = Conceals.new(bufnr, window_id, first_row, last_row, old_mode)
  local virt_lines = VirtLines.new(bufnr, first_row, last_row)
  local lines = Lines.new(window_id, first_column, last_column, conceals, folds, fillers, virt_lines, options.wrap)

  local row_offset = first_row - 1
  local cursor_row = cursor.row + fillers:offset(cursor.row) - row_offset
  local corsor_column = cursor.column - conceals:offset_from_origin(cursor.row, cursor.column + 1)
  local cursor_pos = Position.new(cursor_row, corsor_column)
  local tbl = {
    window_id = window_id,
    lines = lines,
    cursor = cursor_pos,
    number_sign_width = number_sign_width,
    _row_offset = row_offset,
    _column = column,
    _width = width,
    _height = height,
    _options = options,
    _conceals = conceals,
    _folds = folds,
    _fillers = fillers,
    _first_row = first_row,
  }
  return setmetatable(tbl, Origin)
end

function Origin.is_floating(self)
  return windowlib.is_floating(self.window_id)
end

function Origin.copy_to_floating_win(self, bufnr)
  local zindex
  if not self:is_floating() then
    zindex = 49 -- == (default - 1)
  end

  local window_id = vim.api.nvim_open_win(bufnr, false, {
    width = self._width,
    height = self._height,
    relative = "win",
    win = self.window_id,
    row = 0,
    col = self._column,
    bufpos = { self._first_row - 1, 0 },
    external = false,
    style = "minimal",
    focusable = false,
    zindex = zindex,
  })

  self.lines:copy_to(bufnr, window_id)

  vim.bo[bufnr].tabstop = self._options.tabstop
  vim.bo[bufnr].softtabstop = self._options.softtabstop
  vim.bo[bufnr].vartabstop = self._options.vartabstop
  vim.bo[bufnr].varsofttabstop = self._options.varsofttabstop
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

  return window_id
end

function Origin.enter(self)
  windowlib.safe_enter(self.window_id)
end

function Origin.jump(self, row, column, mode)
  row = row + self._row_offset
  local origin_row = row - self._fillers:offset_from_origin(row)

  local insert_offset = 1 -- for stopinsert
  if mode == "n" then
    insert_offset = 0
  end
  column = column + insert_offset
  local origin_column = column + self._conceals:offset(origin_row, column)

  windowlib.jump(self.window_id, origin_row, origin_column)
  return origin_row, origin_column
end

-- HACK
function Origin._view_height(first_row, last_row)
  local saved = vim.fn.winsaveview()

  local scrolloff = vim.api.nvim_get_option_value("scrolloff", { scope = "local" })
  vim.api.nvim_set_option_value("scrolloff", 0, { scope = "local" })

  vim.cmd.normal({
    args = { tostring(first_row) .. "gg" },
    bang = true,
    mods = { silent = true, emsg_silent = true, noautocmd = true, keepjumps = true },
  })
  local win_first_row = vim.fn.winline()
  vim.fn.winrestview(saved)

  vim.cmd.normal({
    args = { tostring(last_row) .. "gg" },
    bang = true,
    mods = { silent = true, emsg_silent = true, noautocmd = true, keepjumps = true },
  })
  local win_last_row = vim.fn.winline()
  vim.api.nvim_set_option_value("scrolloff", scrolloff, { scope = "local" })
  vim.fn.winrestview(saved)

  return win_last_row - win_first_row + 1
end

return Origin
