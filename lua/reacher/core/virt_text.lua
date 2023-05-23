local VirtTexts = {}
VirtTexts.__index = VirtTexts

function VirtTexts.new(bufnr, first_row, last_row, first_column, last_column)
  vim.validate({
    bufnr = { bufnr, "number" },
    first_row = { first_row, "number" },
    last_row = { last_row, "number" },
    first_column = { first_column, "number" },
    last_column = { last_column, "number" },
  })

  local marks = vim.api.nvim_buf_get_extmarks(
    bufnr,
    -1,
    { 0, first_row - 1 },
    { last_row + 1, -1 },
    { details = true, type = "virt_text" }
  )
  marks = vim.tbl_map(function(mark)
    local details = mark[4]
    return {
      row = mark[2],
      column = mark[3],
      virt_text = details.virt_text,
      virt_text_pos = details.virt_text_pos,
    }
  end, marks)
  marks = vim.tbl_filter(function(mark)
    return mark.virt_text_pos == "inline" and mark.column <= last_column
  end, marks)

  local tbl = {
    _marks = marks,
    _first_row = first_row,
  }
  return setmetatable(tbl, VirtTexts)
end

function VirtTexts.set(self, bufnr)
  local ns = vim.api.nvim_create_namespace("reacher_virt_text")
  for _, mark in ipairs(self._marks) do
    local row = mark.row - (self._first_row - 1)
    if row < 0 then
      goto continue
    end
    vim.api.nvim_buf_set_extmark(bufnr, ns, row, mark.column, {
      virt_text = mark.virt_text,
      virt_text_pos = mark.virt_text_pos,
    })
    ::continue::
  end
end

return VirtTexts
