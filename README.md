# reacher.nvim

This plugin introduces displayed range search buffer.
(Required neovim nightly)

<img src="https://raw.github.com/wiki/notomo/reacher.nvim/image/demo4.gif">

## Example

```lua
-- search in the current window
vim.keymap.set({ "n", "x" }, "gs", [[<Cmd>lua require("reacher").start()<CR>]])

-- search in the all windows in the current tab
vim.keymap.set({ "n", "x" }, "gS", [[<Cmd>lua require("reacher").start_multiple()<CR>]])

-- search in the current line
vim.keymap.set({ "n", "x" }, "gl", function()
  require("reacher").start({
    first_row = vim.fn.line("."),
    last_row = vim.fn.line("."),
  })
end)

local group = "reacher_setting"
vim.api.nvim_create_augroup(group, {})
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = group,
  pattern = { "reacher" },
  callback = function()
    vim.keymap.set({ "n", "i" }, "<CR>", [[<Cmd>lua require("reacher").finish()<CR>]], { buffer = true })
    vim.keymap.set({ "n", "i" }, "<ESC>", [[<Cmd>lua require("reacher").cancel()<CR>]], { buffer = true })

    vim.keymap.set("n", "gg", [[<Cmd>lua require("reacher").first()<CR>]], { buffer = true })
    vim.keymap.set("n", "G", [[<Cmd>lua require("reacher").last()<CR>]], { buffer = true })
    vim.keymap.set("n", "j", [[<Cmd>lua require("reacher").next()<CR>]], { buffer = true })
    vim.keymap.set("n", "k", [[<Cmd>lua require("reacher").previous()<CR>]], { buffer = true })

    vim.keymap.set("i", "<Tab>", [[<Cmd>lua require("reacher").next()<CR>]], { buffer = true })
    vim.keymap.set("i", "<S-Tab>", [[<Cmd>lua require("reacher").previous()<CR>]], { buffer = true })
    vim.keymap.set("i", "<C-n>", [[<Cmd>lua require("reacher").forward_history()<CR>]], { buffer = true })
    vim.keymap.set("i", "<C-p>", [[<Cmd>lua require("reacher").backward_history()<CR>]], { buffer = true })
  end,
})
```