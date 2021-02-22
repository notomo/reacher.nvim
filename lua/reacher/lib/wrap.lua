local messagelib = require("reacher.lib.message")

local M = {}

function M.traceback(f)
  return function()
    local ok, result = xpcall(f, debug.traceback)
    if not ok then
      return messagelib.error(result)
    end
    return result
  end
end

return M
