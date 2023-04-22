local vim = vim

local M = {}
M.__index = M

function M.new(key, opts)
  opts = opts or {}
  local tbl = {
    _key = key,
    _filter = opts.filter or function(_)
      return true
    end,
    _current_history = nil,
  }
  return setmetatable(tbl, M)
end

function M.recall(self, offset, before)
  self:_save_if_first(before)

  local index = self:_index()

  local max = 0
  local min = -vim.fn.histnr(self._key)
  for _ = 0, min, -1 do
    index = index + offset

    if index < min or max < index then
      return nil
    end

    local history = vim.fn.histget(self._key, index)
    if self._filter(history) then
      self._current_history = history
      return history
    end
  end
end

function M.save(self, history)
  if not self._filter(history) then
    return false
  end
  vim.fn.histadd(self._key, history)
  return true
end

function M._save_if_first(self, before)
  if self._current_history or not before then
    return
  end
  local saved = self:save(before)
  if not saved then
    return nil
  end
  self._current_history = before
end

function M._index(self)
  local count = vim.fn.histnr(self._key)
  for index = -1, -count, -1 do
    local history = vim.fn.histget(self._key, index)
    if history == self._current_history then
      return index
    end
  end
  return 0
end

return M
