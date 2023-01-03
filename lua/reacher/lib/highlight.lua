local windowlib = require("reacher.lib.window")

local M = require("reacher.vendor.misclib.highlight")

function M.define_from_background(prefix, window_id, opts)
  local winhighlight = {}
  for _, hl in ipairs(vim.split(vim.wo[window_id].winhighlight, ",", { plain = true })) do
    local k, v = unpack(vim.split(hl, ":", { plain = true }))
    winhighlight[k] = v
  end

  local bg_hl_group
  if windowlib.is_floating(window_id) then
    bg_hl_group = winhighlight["NormalFloat"] or winhighlight["Normal"] or "NormalFloat"
  else
    bg_hl_group = winhighlight["Normal"] or "Normal"
  end

  local guibg = vim.api.nvim_win_call(window_id, function()
    return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(bg_hl_group)), "bg", "gui")
  end)
  if guibg == "" then
    guibg = opts.bg_default
  end

  local guifg = vim.api.nvim_win_call(window_id, function()
    return vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID(opts.fg_hl_group)), "fg", "gui")
  end)
  if guifg == "" then
    guifg = opts.fg_default
  end

  local name = prefix .. bg_hl_group
  vim.api.nvim_set_hl(0, name, {
    fg = guifg,
    bg = guibg,
  })
  return name
end

return M
