local vim = vim

local Folds = {}
Folds.__index = Folds

function Folds.new(window_id, s, e, fillers)
  vim.validate({
    window_id = { window_id, "number" },
    s = { s, "number" },
    e = { e, "number" },
    fillers = { fillers, "table" },
  })
  local tbl = { _folds = {} }
  local self = setmetatable(tbl, Folds)

  if not vim.wo[window_id].foldenable then
    return self
  end

  vim.api.nvim_win_call(window_id, function()
    local row = s
    while row <= e do
      local end_row = vim.fn.foldclosedend(row)
      if end_row ~= -1 then
        local offset = fillers:offset(row)
        table.insert(self._folds, { row + offset - s + 1, end_row + offset - s + 1 })
        row = end_row + 1
      else
        row = row + 1
      end
    end
  end)

  return self
end

function Folds.execute(self, window_id)
  vim.api.nvim_win_call(window_id, function()
    for _, range in ipairs(self._folds) do
      vim.cmd.fold({ range = range })
    end
  end)
end

function Folds.apply_to(self, lines)
  for _, row in self:_rows() do
    lines[row].str = ""
  end
  return lines
end

function Folds.exists(self)
  return #self._folds > 0
end

function Folds._rows(self)
  local rows = {}
  for _, range in ipairs(self._folds) do
    for i = range[1], range[2], 1 do
      table.insert(rows, i)
    end
  end
  return ipairs(rows)
end

return Folds
