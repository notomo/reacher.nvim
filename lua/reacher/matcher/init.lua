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

function Matcher.match(self, str, row, column, column_offset, pattern)
  return self._default_method(self, str, row, column, column_offset, pattern)
end

function Matcher.match_all(self, str, row, start_column, pattern)
  local targets = {}
  local column_offset = start_column
  repeat
    local target = self:match(str, row, 0, column_offset, pattern)
    if not target then
      break
    end
    table.insert(targets, target)
    column_offset = target.column_end
  until target == nil
  return targets
end

function Matcher.match_targets(self, original_targets, pattern)
  local targets = {}
  for _, t in ipairs(original_targets) do
    local target = self:match(t.str, t.row, t.column, 0, pattern)
    if target then
      table.insert(targets, target)
    end
  end
  return targets
end

function Matcher.__index(self, k)
  return rawget(Matcher, k) or self._matcher[k]
end

return M
