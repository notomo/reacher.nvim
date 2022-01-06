local M = {}

function M.close(id)
  vim.validate({ id = { id, "number" } })
  if not vim.api.nvim_win_is_valid(id) then
    return
  end
  vim.api.nvim_win_close(id, true)
end

function M.enter(id)
  vim.validate({ id = { id, "number" } })
  if not vim.api.nvim_win_is_valid(id) then
    return
  end
  vim.api.nvim_set_current_win(id)
end

function M.jump(id, row, column)
  vim.validate({ id = { id, "number" }, row = { row, "number" }, column = { column, "number" } })
  M.enter(id)
  vim.cmd("normal! m'")
  vim.api.nvim_win_set_cursor(id, { row, column })
end

function M.is_floating(id)
  vim.validate({ id = { id, "number" } })
  return vim.api.nvim_win_get_config(id).relative ~= ""
end

function M._offset(border, i)
  local e = border[i]
  if e == "" then
    return 0
  end
  if type(e) == "table" and e[1] == "" then
    return 0
  end
  return 1
end

function M.both_sides_border_offsets(config)
  local border = config.border or vim.fn["repeat"]({ "" }, 8)

  local row_offset = 0
  row_offset = row_offset + M._offset(border, 2)
  row_offset = row_offset + M._offset(border, 6)

  local column_offset = 0
  column_offset = column_offset + M._offset(border, 4)
  column_offset = column_offset + M._offset(border, 8)

  return row_offset, column_offset
end

function M.one_side_border_offsets(config)
  local border = config.border or vim.fn["repeat"]({ "" }, 8)
  local row_offset = M._offset(border, 2)
  local column_offset = M._offset(border, 4)
  return row_offset, column_offset
end

return M
