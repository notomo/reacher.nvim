local M = require("reacher.vendor.misclib.window")

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
