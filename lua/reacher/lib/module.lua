local M = {}

function M.find(path)
  vim.validate({path = {path, "string"}})
  local ok, module = pcall(require, path:gsub("/", "."))
  if not ok then
    return nil
  end
  return module
end

local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
function M.cleanup()
  local dir = plugin_name .. "/"
  local dot = plugin_name .. "."
  for key in pairs(package.loaded) do
    if (vim.startswith(key, dir) or vim.startswith(key, dot) or key == plugin_name) then
      package.loaded[key] = nil
    end
  end
end

return M
