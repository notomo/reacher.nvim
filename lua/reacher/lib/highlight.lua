local M = {}

local Highlighter = {}
Highlighter.__index = Highlighter

function Highlighter.add(self, hl_group, row, start_col, end_col)
  vim.api.nvim_buf_add_highlight(self._bufnr, self._ns, hl_group, row, start_col, end_col)
end

function Highlighter.add_virtual(self, hl_group, row, start_col, _, str)
  vim.api.nvim_buf_set_extmark(self._bufnr, self._ns, row, start_col, {
    virt_text = {{str, hl_group}},
    virt_text_pos = "overlay",
  })
end

local HlFactory = {}
HlFactory.__index = HlFactory
M.HlFactory = HlFactory

function HlFactory.new(key, bufnr)
  vim.validate({key = {key, "string"}, bufnr = {bufnr, "number", true}})
  local ns = vim.api.nvim_create_namespace(key)
  local tbl = {_ns = ns, _bufnr = bufnr}
  return setmetatable(tbl, HlFactory)
end

function HlFactory.create(self, bufnr)
  bufnr = bufnr or self._bufnr
  local highlighter = {_bufnr = bufnr, _ns = self._ns}
  return setmetatable(highlighter, Highlighter)
end

function HlFactory.reset(self, bufnr)
  bufnr = bufnr or self._bufnr
  local highlighter = self:create(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, self._ns, 0, -1)
  return highlighter
end

function M.set_background(name, window_id, opts)
  local bg_hl_group = "Normal"
  if vim.api.nvim_win_get_config(window_id).relative ~= "" then
    bg_hl_group = "NormalFloat"
  end
  local guibg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(bg_hl_group)), "bg", "gui")
  if guibg == "" then
    guibg = opts.bg_default
  end

  local guifg = vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(opts.fg_hl_group)), "fg", "gui")
  if guifg == "" then
    guifg = opts.fg_default
  end

  local cmd = ("highlight! %s guibg=%s guifg=%s"):format(name, guibg, guifg)
  vim.cmd(cmd)
end

function M.link(from, to, force)
  local cmd = "highlight default"
  if force then
    cmd = "highlight!"
  end
  vim.cmd(("%s link %s %s"):format(cmd, from, to))
end

return M
