local vim = vim

local M = {}

local ConcealLine = {}
ConcealLine.__index = ConcealLine
M.ConcealLine = ConcealLine

function ConcealLine.new(window_id, row, disable)
  local line = vim.api.nvim_win_call(window_id, function()
    return vim.fn.getline(row)
  end)

  if disable then
    local tbl = { str = line, _offsets = {} }
    return setmetatable(tbl, ConcealLine)
  end

  local syn_conceals
  vim.api.nvim_win_call(window_id, function()
    syn_conceals = vim
      .iter(vim.fn.range(1, #line))
      :map(function(col)
        return vim.fn.synconcealed(row, col)
      end)
      :totable()
  end)

  local chars = {}
  local offsets = {}
  local concealed_count = 0
  for i, conceal in ipairs(syn_conceals) do
    local next_conceal = syn_conceals[i + 1]
    local is_edge = (next_conceal and conceal[3] ~= next_conceal[3]) or not next_conceal
    local text = conceal[2]

    local concealed = conceal[1] == 1
    if concealed then
      concealed_count = concealed_count + 1
    end

    if concealed and is_edge then
      table.insert(chars, text)
    elseif not concealed then
      table.insert(chars, line:sub(i, i))
    end

    if is_edge then
      local offset = concealed_count - #text
      offsets[i - offset] = offset
    end
  end

  local str = table.concat(chars, "")
  local tbl = { str = str, _offsets = offsets }
  return setmetatable(tbl, ConcealLine)
end

function ConcealLine.offset(self, column)
  local nearest_col = 0
  for c in pairs(self._offsets) do
    if nearest_col < c and c <= column then
      nearest_col = c
    end
  end
  return self._offsets[nearest_col] or 0
end

function ConcealLine.offset_from_origin(self, column)
  local nearest_col = 0
  for c, offset in pairs(self._offsets) do
    if nearest_col < c and c + offset <= column then
      nearest_col = c
    end
  end
  return self._offsets[nearest_col] or 0
end

local Conceals = {}
Conceals.__index = Conceals
M.Conceals = Conceals

function Conceals.new(bufnr, window_id, s, e, old_mode)
  vim.validate({
    bufnr = { bufnr, "number" },
    window_id = { window_id, "number" },
    s = { s, "number" },
    e = { e, "number" },
    old_mode = { old_mode, "table" },
  })
  local tbl = { _bufnr = bufnr, _conceals = {}, _lookup = {}, _first_row = s, _last_row = e }
  local self = setmetatable(tbl, Conceals)

  if vim.wo[window_id].conceallevel == 0 then
    return self
  end

  local has_no_conceal_range = not old_mode:is_in(vim.wo[window_id].concealcursor)
  local row = s
  while row <= e do
    local conceal = ConcealLine.new(window_id, row, has_no_conceal_range and old_mode:in_range(row))
    self._lookup[row] = conceal
    table.insert(self._conceals, conceal)
    row = row + 1
  end

  return self
end

function Conceals.lines(self)
  if #self._conceals == 0 then
    return vim.api.nvim_buf_get_lines(self._bufnr, self._first_row - 1, self._last_row, true)
  end
  return vim
    .iter(self._conceals)
    :map(function(conceal)
      return conceal.str
    end)
    :totable()
end

function Conceals.offset(self, row, column)
  local conceal = self._lookup[row]
  if not conceal then
    return 0
  end
  return conceal:offset(column)
end

function Conceals.offset_from_origin(self, row, column)
  local conceal = self._lookup[row]
  if not conceal then
    return 0
  end
  return conceal:offset_from_origin(column)
end

return M
