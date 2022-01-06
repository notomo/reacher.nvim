local M = {}

function M.find(path)
  vim.validate({ path = { path, "string" } })
  local ok, module = pcall(require, path:gsub("/", "."))
  if not ok then
    return nil
  end
  return module
end

return M
