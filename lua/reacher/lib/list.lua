local M = {}

-- NOTE: keeps metatable unlike vim.fn.reverse(tbl)
function M.reverse(tbl)
  local new_tbl = {}
  for i = #tbl, 1, -1 do
    table.insert(new_tbl, tbl[i])
  end
  return new_tbl
end

return M
