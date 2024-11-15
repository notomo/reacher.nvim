local M = {}

function M.validate(tbl)
  local errs = {}
  for key, value in pairs(tbl) do
    local ok, result = pcall(vim.validate, key, unpack(value))
    if not ok then
      local msg_head = vim.split(tostring(result), "\n")[1]
      table.insert(errs, ("%s: %s"):format(msg_head, vim.inspect(value[1])))
    end
  end
  if #errs ~= 0 then
    return table.concat(errs, "\n")
  end
end

return M
