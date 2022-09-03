local windowlib = require("reacher.lib.window")
local cursorlib = require("reacher.lib.cursor")
local wraplib = require("reacher.lib.wrap")
local vim = vim

local M = {}

local Inputter = {}
Inputter.__index = Inputter
M.Inputter = Inputter

function Inputter.open(callback, on_insert_enter, on_insert_leave, default_input)
  vim.validate({ callback = { callback, "function" }, default_input = { default_input, "string", true } })
  default_input = default_input or ""

  local bufnr = vim.api.nvim_create_buf(false, true)
  local window_id = vim.api.nvim_open_win(bufnr, true, {
    width = vim.o.columns,
    height = 1,
    relative = "editor",
    row = vim.o.lines - vim.o.cmdheight - 1, -- HACK: over statusline
    col = 0,
    external = false,
    style = "minimal",
  })
  local name = "reacher://REACHER"
  local old = vim.fn.bufnr(("^%s$"):format(name))
  if old ~= -1 then
    vim.api.nvim_buf_delete(old, { force = true })
  end
  vim.api.nvim_echo({}, false, {}) -- NOTE: for clear command-line
  vim.api.nvim_buf_set_name(bufnr, "reacher://REACHER")
  vim.bo[bufnr].bufhidden = "wipe"
  vim.bo[bufnr].filetype = "reacher"
  vim.wo[window_id].winhighlight = "Normal:Normal,SignColumn:Normal"
  vim.wo[window_id].signcolumn = "yes:1"

  vim.api.nvim_create_autocmd({ "WinClosed", "WinLeave", "TabLeave", "BufLeave", "BufWipeout" }, {
    once = true,
    buffer = bufnr,
    callback = function()
      require("reacher.command").close(window_id)
    end,
  })
  vim.api.nvim_create_autocmd({ "InsertLeave" }, {
    buffer = bufnr,
    callback = on_insert_leave,
  })
  vim.api.nvim_create_autocmd({ "InsertEnter" }, {
    buffer = bufnr,
    callback = on_insert_enter,
  })

  local tbl = { window_id = window_id, _bufnr = bufnr, _history_offset = 0 }
  local self = setmetatable(tbl, Inputter)

  vim.api.nvim_buf_attach(bufnr, false, {
    on_lines = wraplib.traceback(function()
      local input_line = self:_get_line()
      callback(input_line)

      if vim.api.nvim_buf_line_count(bufnr) == 1 then
        return
      end
      vim.schedule(function()
        vim.api.nvim_buf_set_lines(bufnr, 1, -1, false, {})
      end)
    end),
  })
  self:_set_line(default_input)
  vim.cmd("startinsert!")

  return self
end

function Inputter._set_line(self, line)
  vim.api.nvim_buf_set_lines(self._bufnr, 0, -1, true, { vim.split(line, "\n", true)[1] })
end

function Inputter._get_line(self)
  return vim.api.nvim_buf_get_lines(self._bufnr, 0, -1, true)[1]
end

function Inputter.recall_history(self, offset)
  if self._history_offset == 0 then
    self:save_history()
  end

  local next_index = self._history_offset + offset
  next_index = math.min(next_index, 0)
  next_index = math.max(next_index, -vim.fn.histnr("search"))

  local history = vim.fn.histget("search", next_index)
  self:_set_line(history)
  cursorlib.set_column(#history + 1)

  self._history_offset = next_index
end

function Inputter.save_history(self, include_register)
  vim.validate({ include_register = { include_register, "boolean", true } })
  local input_line = self:_get_line()
  vim.fn.histadd("search", input_line)
  if include_register then
    vim.fn.setreg("/", input_line)
  end
end

function Inputter.close(self, is_cancel)
  vim.validate({ is_cancel = { is_cancel, "boolean", true } })

  -- NOTICE: because sometimes the buffer is not deleted.
  vim.api.nvim_buf_delete(self._bufnr, { force = true })
  windowlib.close(self.window_id)

  local insert_mode = vim.api.nvim_get_mode().mode == "i"
  if not insert_mode then
    return
  end
  vim.cmd("stopinsert")

  if is_cancel then
    local row, column = unpack(vim.api.nvim_win_get_cursor(0))
    vim.api.nvim_win_set_cursor(0, { row, column + 1 })
  end
end

return M
