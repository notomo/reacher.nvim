local vim = vim

local M = {}

function M.startswith(self, str, row, column, column_offset, pattern)
  if pattern == "" then
    pattern = "."
  end

  local ok, result = pcall(vim.fn.matchstrpos, str, "^" .. pattern, column_offset)
  if not ok then
    return nil
  end

  local matched, s, e = unpack(result)
  if s == e then
    return nil
  end

  return self.new_target(row, column + s, column + e, matched)
end

function M.partial(self, str, row, column, column_offset, pattern)
  if pattern == "" then
    pattern = ".*"
  end

  local ok, result = pcall(vim.fn.matchstrpos, str, pattern, column_offset)
  if not ok then
    return nil
  end

  local matched, s, e = unpack(result)
  if s == e then
    return nil
  end

  return self.new_target(row, column + s, column + e, matched)
end

return M
