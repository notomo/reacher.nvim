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

function M.recall(self, offset, current)
  local index = self:_index(self._current_history)

  local will_save = current and self._current_history ~= current
  local will_delete = will_save and index == -1

  local max = 0
  local min = -vim.fn.histnr(self._key)
  for _ = 0, min, -1 do
    index = index + offset

    if index < min or max < index then
      return nil
    end

    local history = vim.fn.histget(self._key, index)
    if self._filter(history) then
      if will_delete then
        vim.fn.histdel(self._key, -1)
      end
      if will_save then
        self:save(current)
      end
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

function M._index(self, target_history)
  local count = vim.fn.histnr(self._key)
  for index = -1, -count, -1 do
    local history = vim.fn.histget(self._key, index)
    if history == target_history then
      return index
    end
  end
  return 0
end

return M
