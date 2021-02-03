local M = {}

local plugin_name = vim.split((...):gsub("%.", "/"), "/", true)[1]
local prefix = ("[%s] "):format(plugin_name)

M.error = function(err)
  vim.api.nvim_err_writeln(prefix .. err)
end

M.warn = function(msg)
  vim.api.nvim_echo({{prefix .. msg, "WarningMsg"}}, true, {})
end

return M
