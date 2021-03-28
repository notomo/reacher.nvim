local highlightlib = require("reacher.lib.highlight")
local windowlib = require("reacher.lib.window")
local cursorlib = require("reacher.lib.cursor")
local wraplib = require("reacher.lib.wrap")
local vim = vim

local M = {}

local Inputter = {}
Inputter.__index = Inputter
M.Inputter = Inputter

Inputter.key_mapping_script = [[
inoremap <buffer> <CR> <Cmd>lua require("reacher").finish()<CR>
inoremap <buffer> <ESC> <Cmd>lua require("reacher").cancel()<CR>
inoremap <buffer> <Tab> <Cmd>lua require("reacher").next()<CR>
inoremap <buffer> <S-Tab> <Cmd>lua require("reacher").previous()<CR>
inoremap <buffer> <C-n> <Cmd>lua require("reacher").forward_history()<CR>
inoremap <buffer> <C-p> <Cmd>lua require("reacher").backward_history()<CR>

nnoremap <buffer> <CR> <Cmd>lua require("reacher").finish()<CR>
nnoremap <nowait> <buffer> <ESC> <Cmd>lua require("reacher").cancel()<CR>
nnoremap <buffer> gg <Cmd>lua require("reacher").first()<CR>
nnoremap <buffer> G <Cmd>lua require("reacher").last()<CR>
nnoremap <buffer> j <Cmd>lua require("reacher").next()<CR>
nnoremap <buffer> k <Cmd>lua require("reacher").previous()<CR>
nnoremap <buffer> l <Cmd>lua require("reacher").side_next()<CR>
nnoremap <buffer> h <Cmd>lua require("reacher").side_previous()<CR>]]

function Inputter.open(callback, default_input)
  vim.validate({callback = {callback, "function"}, default_input = {default_input, "string", true}})
  default_input = default_input or ""

  local bufnr = vim.api.nvim_create_buf(false, true)
  local window_id = vim.api.nvim_open_win(bufnr, true, {
    width = vim.o.columns,
    height = 1,
    relative = "editor",
    row = 10000,
    col = 0,
    external = false,
    style = "minimal",
  })
  local name = "reacher://REACHER"
  local old = vim.fn.bufnr(("^%s$"):format(name))
  if old ~= -1 then
    vim.api.nvim_buf_delete(old, {force = true})
  end
  vim.api.nvim_exec(Inputter.key_mapping_script, false)
  vim.api.nvim_buf_set_name(bufnr, "reacher://REACHER")
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].filetype = "reacher"
  vim.wo[window_id].winhighlight = "Normal:Normal,SignColumn:Normal"
  vim.wo[window_id].signcolumn = "yes:1"

  local on_leave = ("autocmd WinClosed,WinLeave,TabLeave,BufLeave,BufWipeout <buffer=%s> ++once lua require('reacher.command').Command.new('close', %s)"):format(bufnr, window_id)
  vim.cmd(on_leave)

  local on_insert_leave = ("autocmd InsertLeave <buffer=%s> lua require('reacher.view.inputter').on_insert_leave()"):format(bufnr)
  vim.cmd(on_insert_leave)

  local on_insert_enter = ("autocmd InsertEnter <buffer=%s> lua require('reacher.view.inputter').on_insert_enter()"):format(bufnr)
  vim.cmd(on_insert_enter)

  vim.api.nvim_buf_attach(bufnr, false, {
    on_lines = wraplib.traceback(function()
      local input_line = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)[1]
      callback(input_line)

      if vim.api.nvim_buf_line_count(bufnr) == 1 then
        return
      end
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(bufnr, 1, -1, false, {})
      end)
    end),
  })
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, {vim.split(default_input, "\n", true)[1]})
  vim.cmd("startinsert!")

  local tbl = {window_id = window_id, _bufnr = bufnr, _history_offset = 0}
  return setmetatable(tbl, Inputter)
end

function Inputter.recall_history(self, offset)
  if self._history_offset == 0 then
    self:save_history()
  end

  local next_index = self._history_offset + offset
  next_index = math.min(next_index, 0)
  next_index = math.max(next_index, -vim.fn.histnr("search"))

  local history = vim.fn.histget("search", next_index)
  vim.api.nvim_buf_set_lines(self._bufnr, 0, -1, true, {history})
  cursorlib.set_column(#history + 1)

  self._history_offset = next_index
end

function Inputter.save_history(self, include_register)
  vim.validate({include_register = {include_register, "boolean", true}})
  local input_line = vim.api.nvim_buf_get_lines(self._bufnr, 0, -1, true)[1]
  vim.fn.histadd("search", input_line)
  if include_register then
    vim.fn.setreg("/", input_line)
  end
end

function Inputter.close(self, is_cancel)
  vim.validate({is_cancel = {is_cancel, "boolean", true}})

  -- NOTICE: because sometimes the buffer is not deleted.
  vim.api.nvim_buf_delete(self._bufnr, {force = true})
  windowlib.close(self.window_id)

  local insert_mode = vim.api.nvim_get_mode().mode == "i"
  if not insert_mode then
    return
  end
  vim.cmd("stopinsert")

  if is_cancel then
    local row, column = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_win_set_cursor(0, {row, column + 1})
  end
end

function M.on_insert_leave()
  highlightlib.link("ReacherCurrentMatch", "ReacherCurrentMatchNormal", true)
end

function M.on_insert_enter()
  highlightlib.link("ReacherCurrentMatch", "ReacherCurrentMatchInsert", true)
end

return M
