local M = {}

function M.startswith(self, str, row, column, input)
  local pattern = input.str
  if pattern == "" then
    pattern = "."
  end

  local ok, result = pcall(vim.fn.matchstrpos, str, "^" .. pattern, 0)
  if not ok then
    return nil
  end

  local matched, s, e = unpack(result)
  if s == e then
    return nil
  end

  return self.new_target(row, column + s, column + e, matched)
end

function M.partial(self, str, row, column, input)
  local pattern = input.str
  if pattern == "" then
    pattern = ".*"
  end

  local ok, result = pcall(vim.fn.matchstrpos, str, pattern, column)
  if not ok then
    return nil
  end

  local matched, s, e = unpack(result)
  if s == e then
    return nil
  end

  return self.new_target(row, s, e, matched)
end

return M
