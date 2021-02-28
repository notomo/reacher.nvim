local vim = vim

local M = {}

M._regex = vim.regex("\\v[[:alnum:]]+")

function M.collect(self, lines)
  local targets = {}
  for row, line in ipairs(lines) do
    targets = vim.list_extend(targets, self:_search(line.str, row))
  end
  if #targets == 0 then
    return nil, "no targets"
  end
  return {targets = targets}
end

function M._search(self, line, row)
  local targets = {}
  local column = 1
  local regex = M._regex
  repeat
    local str = line:sub(column)
    local s, e = regex:match_str(str)
    if s ~= nil then
      table.insert(targets, self.new_target(row, column + s - 1, column + s, str:sub(s + 1, e)))
      column = column + e + 1
    end
  until s == nil
  return targets
end

function M.filter(_, ctx, result)
  local input = ctx.input
  local targets = vim.tbl_filter(function(target)
    local str, input_str = input:apply_smartcase(target.str)
    return vim.startswith(str, input_str)
  end, result.targets)

  local input_width = #input.str
  if input_width == 0 then
    return targets
  end

  return vim.tbl_map(function(target)
    return target:change_width(input_width)
  end, targets)
end

return M
