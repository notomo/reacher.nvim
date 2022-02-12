local M = {}

local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local prefix = ("[%s] "):format(plugin_name)

function M.error(err)
  error(M.wrap(err))
end

function M.warn(msg)
  vim.api.nvim_echo({ { M.wrap(msg), "WarningMsg" } }, true, {})
end

function M.info(msg)
  vim.api.nvim_echo({ { M.wrap(msg) } }, true, {})
end

function M.wrap(msg)
  if type(msg) == "string" then
    return prefix .. msg
  end
  return prefix .. vim.inspect(msg)
end

function M.validate(tbl)
  local errs = {}
  for key, value in pairs(tbl) do
    local ok, result = pcall(vim.validate, { [key] = value })
    if not ok then
      local msg_head = vim.split(result, "\n")[1]
      table.insert(errs, ("%s: %s"):format(msg_head, vim.inspect(value[1])))
    end
  end
  if #errs ~= 0 then
    return table.concat(errs, "\n")
  end
end

return M
