local util = require("genvdoc.util")
local plugin_name = vim.env.PLUGIN_NAME
local full_plugin_name = plugin_name .. ".nvim"

local usage_path = ("./spec/lua/%s/usage.vim"):format(plugin_name)

require("genvdoc").generate(full_plugin_name, {
  chapters = {
    {
      name = function(group)
        return "Lua module: " .. group
      end,
      group = function(node)
        if not node.declaration then
          return nil
        end
        return node.declaration.module
      end,
    },
    {
      name = "USAGE",
      body = function()
        local usage = util.help_code_block_from_file(usage_path)
        local mappings = require("reacher.view.inputter").Inputter.key_mapping_script
        local hl_groups = require("reacher.view.overlay").Overlay.hl_group_script
        local body = usage:gsub([[    " {mappings}]], util.indent(mappings, 4))
        body = body:gsub([[  " {hl_groups}]], util.indent(hl_groups, 2))
        return body
      end,
    },
  },
})

local gen_readme = function()
  local f = io.open(usage_path, "r")
  local usage = f:read("*a")
  local mappings = require("reacher.view.inputter").Inputter.key_mapping_script
  local hl_groups = require("reacher.view.overlay").Overlay.hl_group_script
  local body = usage:gsub([[  " {mappings}]], util.indent(mappings, 2))
  body = body:gsub([[" {hl_groups}]], hl_groups)
  f:close()

  local content = ([[
# %s

This plugin introduces displayed range search buffer.
(Required neovim nightly)

<img src="https://raw.github.com/wiki/notomo/reacher.nvim/image/demo4.gif" width="1280">

## Usage

```vim
%s```]]):format(full_plugin_name, body)

  local readme = io.open("README.md", "w")
  readme:write(content)
  readme:close()
end
gen_readme()
