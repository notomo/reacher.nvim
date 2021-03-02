local Target = require("reacher.model.target").Target
local modulelib = require("reacher.lib.module")

local M = {}

local Matcher = {}
Matcher.__index = Matcher
M.Matcher = Matcher

function Matcher.new(name, method_name)
  vim.validate({name = {name, "string"}, method_name = {method_name, "string", true}})
  method_name = method_name or "partial"

  local matcher = modulelib.find("reacher.matcher." .. name)
  if matcher == nil then
    return nil, "not found matcher: " .. name
  end

  local default_method = matcher[method_name]
  if default_method == nil or type(default_method) ~= "function" then
    return nil, ("not found %s matcher function: %s"):format(name, method_name)
  end

  local tbl = {
    name = name,
    _matcher = matcher,
    _default_method = default_method,
    new_target = Target.new,
    new_virtual_target = Target.new_virtual,
  }
  return setmetatable(tbl, Matcher)
end

function Matcher.match(self, target, input)
  return self._default_method(self, target.str, target.row, target.column, input)
end

function Matcher.match_str(self, ...)
  return self._default_method(self, ...)
end

function Matcher.__index(self, k)
  return rawget(Matcher, k) or self._matcher[k]
end

return M
