local M = {}

local Highlighter = {}
Highlighter.__index = Highlighter

function Highlighter.add(self, hl_group, row, start_col, end_col)
  vim.api.nvim_buf_add_highlight(self.bufnr, self.ns, hl_group, row, start_col, end_col)
end

local HlFactory = {}
HlFactory.__index = HlFactory
M.HlFactory = HlFactory

function HlFactory.new(key, bufnr)
  vim.validate({key = {key, "string"}, bufnr = {bufnr, "number", true}})
  local ns = vim.api.nvim_create_namespace(key)
  local tbl = {ns = ns, bufnr = bufnr}
  return setmetatable(tbl, HlFactory)
end

function HlFactory.create(self, bufnr)
  bufnr = bufnr or self.bufnr
  local highlighter = {bufnr = bufnr, ns = self.ns}
  return setmetatable(highlighter, Highlighter)
end

function HlFactory.reset(self, bufnr)
  bufnr = bufnr or self.bufnr
  local highlighter = self:create(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, self.ns, 0, -1)
  return highlighter
end

M.set_background = function(name, window_id, opts)
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
  vim.api.nvim_command(cmd)
end

M.link = function(from, to)
  vim.api.nvim_command(("highlight default link %s %s"):format(from, to))
end

return M
