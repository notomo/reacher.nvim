local vim = vim

local M = {}

function M.match(_, str, pattern, column_offset)
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

  return matched, s, e
end

return M
