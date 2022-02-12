local M = {}

local VirtLines = {}
VirtLines.__index = VirtLines
M.VirtLines = VirtLines

function VirtLines.new(bufnr, first_row, last_row)
  vim.validate({
    bufnr = { bufnr, "number" },
    first_row = { first_row, "number" },
    last_row = { last_row, "number" },
  })

  local all_marks = {}

  local nss = vim.api.nvim_get_namespaces()
  for _, ns in pairs(nss) do
    local ok, marks = pcall(
      vim.api.nvim_buf_get_extmarks,
      bufnr,
      ns,
      { 0, first_row - 1 },
      { last_row + 1, -1 },
      { details = true }
    )
    if not ok then
      goto continue
    end

    marks = vim.tbl_map(function(mark)
      local details = mark[4]
      return {
        row = mark[2],
        column = mark[3],
        virt_lines = details.virt_lines,
        virt_lines_above = details.virt_lines_above,
      }
    end, marks)
    marks = vim.tbl_filter(function(mark)
      return mark.virt_lines ~= nil
    end, marks)

    vim.list_extend(all_marks, marks)

    ::continue::
  end

  local tbl = {
    _marks = all_marks,
    _first_row = first_row,
  }
  return setmetatable(tbl, VirtLines)
end

function VirtLines.set(self, bufnr)
  local ns = vim.api.nvim_create_namespace("reacher_virt_lines")
  for _, mark in ipairs(self._marks) do
    local row = mark.row - (self._first_row - 1)
    if row < 0 then
      goto continue
    end
    vim.api.nvim_buf_set_extmark(bufnr, ns, row, mark.column, {
      virt_lines = mark.virt_lines,
      virt_lines_above = mark.virt_lines_above,
    })
    ::continue::
  end
end

return M
