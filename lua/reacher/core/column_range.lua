local vim = vim

local M = {}

local ColumnRange = {}
ColumnRange.__index = ColumnRange
M.ColumnRange = ColumnRange

function ColumnRange.new(str, virtual_s, virtual_e)
  local trimmed = str
  local _, s, e = unpack(vim.fn.matchstrpos(str, "\\%>" .. virtual_s .. "v.*\\%<" .. virtual_e .. "v"))
  if s == e then
    return ColumnRange.new_default("")
  end
  trimmed = str:sub(1, e)

  local tbl = { str = trimmed, s = s }
  return setmetatable(tbl, ColumnRange)
end

function ColumnRange.new_default(str)
  local tbl = { str = str, s = 0 }
  return setmetatable(tbl, ColumnRange)
end

local ColumnRanges = {}
ColumnRanges.__index = ColumnRanges
M.ColumnRanges = ColumnRanges

--- @param window_id integer
--- @param line_strs string[]
--- @param virtual_s integer
--- @param virtual_e integer
--- @param wrap boolean
function ColumnRanges.new(window_id, line_strs, virtual_s, virtual_e, wrap)
  local tbl = { _column_ranges = {} }
  local self = setmetatable(tbl, ColumnRanges)

  local strs = vim.deepcopy(line_strs)
  if wrap then
    self._column_ranges = vim
      .iter(strs)
      :map(function(str)
        return ColumnRange.new_default(str)
      end)
      :totable()
    local last_line = vim.api.nvim_win_call(window_id, function()
      return M.calc_displayed_last_line()
    end)
    if last_line then
      table.insert(self._column_ranges, ColumnRange.new_default(last_line))
    end
    return self
  end

  local vs = virtual_s - 1
  local ve = virtual_e + 2
  for _, str in ipairs(strs) do
    table.insert(self._column_ranges, ColumnRange.new(str, vs, ve))
  end
  return self
end

function ColumnRanges.iter(self)
  return ipairs(self._column_ranges)
end

-- HACK: for wrapped last line lying on the window bottom
function M.calc_displayed_last_line()
  local height = vim.api.nvim_win_get_height(0)
  local count = vim.fn.line("$")
  if height > count then
    return nil
  end

  local saved = vim.fn.winsaveview()
  local scrolloff = vim.api.nvim_get_option_value("scrolloff", { scope = "local" })
  vim.api.nvim_set_option_value("scrolloff", 0, { scope = "local" })
  local reset = function()
    vim.api.nvim_set_option_value("scrolloff", scrolloff, { scope = "local" })
    vim.fn.winrestview(saved)
  end

  local last_row = vim.fn.line("w$")
  vim.cmd.normal({
    args = { tostring(last_row) .. "gg" },
    bang = true,
    mods = { silent = true, emsg_silent = true, noautocmd = true, keepjumps = true },
  })
  local rest_height = height - vim.fn.winline()

  vim.cmd.normal({ args = { "j" }, bang = true, mods = { silent = true, emsg_silent = true, noautocmd = true } })
  vim.cmd.normal({ args = { "g0" }, bang = true, mods = { silent = true, emsg_silent = true, noautocmd = true } })

  if height - vim.fn.winline() <= 0 then
    return reset()
  end
  local row = vim.fn.line(".")
  local column = vim.fn.col(".")
  local line = vim.fn.getline(row)
  local line_length = #line
  local is_wrapped = false
  while true do
    vim.cmd.normal({ args = { "gj" }, bang = true, mods = { silent = true, emsg_silent = true, noautocmd = true } })
    local r = vim.fn.line(".")
    local c = vim.fn.col(".")
    if r ~= row or (row == r and column == c) then
      break
    end
    is_wrapped = true

    if vim.fn.col("$") == line_length then
      return reset()
    end

    column = c
    rest_height = rest_height - 1
    if rest_height <= 0 then
      break
    end
  end

  if not is_wrapped then
    return reset()
  end

  reset()
  return line:sub(1, column - 1)
end

return M
