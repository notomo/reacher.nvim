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
  if not (self.smartcase and self:has_uppercase(pattern)) then
    return pattern
  end
  return "\\C" .. pattern
end

function M.has_uppercase(_, pattern)
  local chars = vim.fn.split(pattern, "\\zs")
  local length = #chars
  local i = 1
  local has = false
  while i <= length do
    local c = chars[i]
    local next_c = chars[i + 1]
    if c == "\\" then
      if next_c == "_" and chars[i + 2] then
        i = i + 3
      elseif next_c == "%" and chars[i + 2] then
        i = i + 3
      elseif next_c then
        -- HACK: \c or \C
        if next_c == "c" or next_c == "C" then
          return false
        end
        i = i + 2
      else
        i = i + 1
      end
    elseif c:lower() ~= c then
      has = true
      i = i + 1
    else
      i = i + 1
    end
  end
  return has
end

return M
