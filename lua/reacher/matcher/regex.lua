local vim = vim

local M = {}

function M.match(self, str, pattern, column_offset)
  if pattern == "" then
    pattern = ".*"
  end

  local ok, result = pcall(vim.fn.matchstrpos, str, self:adjust_case(pattern), column_offset)
  if not ok then
    return nil
  end

  local matched, s, e = unpack(result)
  if s == e then
    return nil
  end

  return matched, s, e
end

function M.adjust_case(self, pattern)
  if not self.smartcase or pattern:find("\\c") or pattern:find("\\C") or not self:has_uppercase(pattern) then
    return pattern
  end
  return "\\C" .. pattern
end

function M.has_uppercase(_, pattern)
  local chars = vim.fn.split(pattern, "\\zs")
  local length = #chars
  local i = 1
  while i <= length do
    local c = chars[i]
    if c == "\\" then
      if chars[i + 1] == "_" and chars[i + 2] then
        i = i + 3
      elseif chars[i + 1] == "%" and chars[i + 2] then
        i = i + 3
      elseif chars[i + 1] then
        i = i + 2
      else
        i = i + 1
      end
    elseif c:lower() ~= c then
      return true
    else
      i = i + 1
    end
  end
  return false
end

return M
