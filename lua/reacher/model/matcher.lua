local modulelib = require("reacher.lib.module")

local M = {}

local Matcher = {}
Matcher.__index = Matcher
M.Matcher = Matcher

function Matcher.new(name)
  vim.validate({name = {name, "string"}})

  local matcher = modulelib.find("reacher.matcher." .. name)
  if matcher == nil then
    return nil, "not found matcher: " .. name
  end

  local tbl = {name = name, _matcher = matcher}
  return setmetatable(tbl, Matcher)
end

function Matcher.must(name)
  local matcher, err = Matcher.new(name)
  if err ~= nil then
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

return M
