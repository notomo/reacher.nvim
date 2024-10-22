local VirtLines = {}
VirtLines.__index = VirtLines

--- @param bufnr integer
--- @param first_row integer
--- @param last_row integer
function VirtLines.new(bufnr, first_row, last_row)
  local marks = vim.api.nvim_buf_get_extmarks(
    bufnr,
    -1,
    { 0, first_row - 1 },
    { last_row + 1, -1 },
    { details = true, type = "virt_lines" }
  )
  marks = vim
    .iter(marks)
    :map(function(mark)
      local details = mark[4]
      return {
        row = mark[2],
        column = mark[3],
        virt_lines = details.virt_lines,
        virt_lines_above = details.virt_lines_above,
      }
    end)
    :totable()

  local tbl = {
    _marks = marks,
    _first_row = first_row,
  }
  return setmetatable(tbl, VirtLines)
end

function VirtLines.set(self, bufnr)
  local ns = vim.api.nvim_create_namespace("reacher_virt_lines")
  vim.iter(self._marks):each(function(mark)
    local row = mark.row - (self._first_row - 1)
    if row < 0 then
      return
    end
    vim.api.nvim_buf_set_extmark(bufnr, ns, row, mark.column, {
      virt_lines = mark.virt_lines,
      virt_lines_above = mark.virt_lines_above,
    })
  end)
end

return VirtLines
