local M = {}

local find = function(path)
  local ok, module = pcall(require, path)
  if not ok then
    return nil
  end
  return module
end

local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
M.cleanup = function()
  local dir = plugin_name .. "/"
  for key in pairs(package.loaded) do
    if (vim.startswith(key, dir) or key == plugin_name) then
      package.loaded[key] = nil
    end
  end
end

-- for app

M.find_source = function(name)
  return find("reacher/source/" .. name)
end

return M
