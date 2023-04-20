local vim = vim
local api = vim.api

local Decorator = {}
Decorator.__index = Decorator

function Decorator.new(ns, bufnr, is_ephemeral)
  vim.validate({
    ns = { ns, "number" },
    bufnr = { bufnr, "number" },
    is_ephemeral = { is_ephemeral, "boolean" },
  })
  local tbl = {
    _ns = ns,
    _bufnr = bufnr,
    _is_ephemeral = is_ephemeral,
  }
  return setmetatable(tbl, Decorator)
end

function Decorator.highlight(self, hl_group, row, start_col, end_col, opts)
  opts = opts or {}

  local end_row
  if end_col == -1 then
    end_col = nil
    end_row = row + 1
  end

  opts.end_row = end_row
  opts.end_col = end_col
  opts.hl_group = hl_group
  opts.ephemeral = self._is_ephemeral
  api.nvim_buf_set_extmark(self._bufnr, self._ns, row, start_col, opts)
end

function Decorator.highlight_line(self, hl_group, row, opts)
  self:highlight(hl_group, row, 0, -1, opts)
end

function Decorator.highlight_range(self, hl_group, start_row, end_row, start_col, end_col, opts)
  opts = opts or {}

  end_row = end_row or start_row
  if end_col == -1 then
    end_col = nil
    end_row = end_row + 1
  end

  opts.end_row = end_row
  opts.end_col = end_col
  opts.hl_group = hl_group
  opts.ephemeral = self._is_ephemeral

  api.nvim_buf_set_extmark(self._bufnr, self._ns, start_row, start_col, opts)
end

function Decorator.add_virtual_text(self, row, start_col, virt_text, opts)
  opts = opts or {}
  opts.virt_text = virt_text
  opts.ephemeral = self._is_ephemeral
  api.nvim_buf_set_extmark(self._bufnr, self._ns, row, start_col, opts)
end

function Decorator.clear(self)
  api.nvim_buf_clear_namespace(self._bufnr, self._ns, 0, -1)
end

local DecoratorFactory = {}
DecoratorFactory.__index = DecoratorFactory

function Decorator.factory(key, bufnr)
  vim.validate({ key = { key, "string" }, bufnr = { bufnr, "number", true } })
  local ns = api.nvim_create_namespace(key)
  local tbl = {
    _ns = ns,
    _bufnr = bufnr,
  }
  return setmetatable(tbl, DecoratorFactory)
end

function DecoratorFactory.create(self, bufnr, is_ephemeral)
  return Decorator.new(self._ns, bufnr or self._bufnr, is_ephemeral or false)
end

function DecoratorFactory.reset(self, bufnr, is_ephemeral)
  local decorator = self:create(bufnr, is_ephemeral)
  decorator:clear()
  return decorator
end

return Decorator
