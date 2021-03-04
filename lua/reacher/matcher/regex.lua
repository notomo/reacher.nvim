local vim = vim

local M = {}

function M.startswith(self, str, pattern, column_offset)
  if pattern == "" then
    pattern = "."
  end
  return self:_match(str, "^" .. pattern, column_offset)
end

function M.partial(self, str, pattern, column_offset)
  if pattern == "" then
    pattern = ".*"
  end
  return self:_match(str, pattern, column_offset)
end

function M._match(_, str, pattern, column_offset)
  local ok, result = pcall(vim.fn.matchstrpos, str, pattern, column_offset)
  if not ok then
    return nil
  end

  local matched, s, e = unpack(result)
  if s == e then
    return nil
  end

  return matched, s, e
end

return M
