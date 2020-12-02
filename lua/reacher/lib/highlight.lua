local M = {}

M.set_background = function(window_id, opts)
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

  local cmd = ("highlight! ReacherBackground guibg=%s guifg=%s"):format(guibg, guifg)
  vim.api.nvim_command(cmd)
end

return M
