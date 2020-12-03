local M = {}

local Node = {}
Node.__index = Node
M.Node = Node

function Node.new()
  local tbl = {}
  return setmetatable(tbl, Node)
end

function Node.add(self, id, name)
  local data = self
  for i = 1, #name do
    local c = name:sub(i, i)
    if data[c] == nil then
      data[c] = {}
      data[c].index = i
      data[c].id = id
      data[c].count = 0
      data[c].data = {}
    end
    data[c].count = data[c].count + 1
    data = data[c].data
  end
end

function Node.search(self, id, name)
  local data = self
  for i = 1, #name do
    local c = name:sub(i, i)
    local d = data[c]
    if d ~= nil and d.id == id and d.count == 1 then
      return d.index
    end
    data = d.data
  end
  return nil
end

return M
