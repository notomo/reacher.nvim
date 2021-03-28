local usage_path = "./spec/lua/reacher/usage.vim"

require("genvdoc").generate("reacher.nvim", {
  chapters = {
    {
      name = function(group)
        return "Lua module: " .. group
      end,
      group = function(node)
        if node.declaration == nil then
          return nil
        end
        return node.declaration.module
      end,
    },
    {
      name = "USAGE",
      body = function()
        local usage = require("genvdoc.util").help_code_block_from_file(usage_path)
        local mappings = require("reacher.view.inputter").Inputter.key_mapping_script
        local indented = require("genvdoc.util").indent(mappings, 4)
        local body = usage:gsub([[    " {mappings}]], indented)
        return body
      end,
    },
  },
})

local gen_readme = function()
  local f = io.open(usage_path, "r")
  local usage = f:read("*a")
  local mappings = require("reacher.view.inputter").Inputter.key_mapping_script
  local indented = require("genvdoc.util").indent(mappings, 2)
  local body = usage:gsub([[  " {mappings}]], indented)
  f:close()

  local content = ([[
# reacher.nvim

This plugin introduces displayed range search buffer.

## Usage

```vim
%s```]]):format(body)

  local readme = io.open("README.md", "w")
  readme:write(content)
  readme:close()
end
gen_readme()
