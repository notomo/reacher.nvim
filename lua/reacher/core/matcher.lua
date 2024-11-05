local modulelib = require("reacher.vendor.misclib.module")
local vim = vim

local Matcher = {}
Matcher.__index = Matcher

--- @param name string
function Matcher.new(name)
  local matcher = modulelib.find("reacher.matcher." .. name)
  if not matcher then
    return "not found matcher: " .. name
  end

  local tbl = { name = name, _matcher = matcher, smartcase = vim.o.smartcase }
  return setmetatable(tbl, Matcher)
end

function Matcher.must(name)
  local matcher = Matcher.new(name)
  if type(matcher) == "string" then
    local err = matcher
    error(err)
  end
  return matcher
end

function Matcher.match(self, str, pattern, column_offset)
  return self._matcher.match(self, str, pattern, column_offset)
end

function Matcher.__index(self, k)
  return rawget(Matcher, k) or self._matcher[k]
end

return Matcher
