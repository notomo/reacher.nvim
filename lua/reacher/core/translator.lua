local Target = require("reacher.core.target").Target
local windowlib = require("reacher.lib.window")
local vim = vim

local Translator = {}
Translator.__index = Translator

--- @param window_id integer
--- @param matcher table
--- @param regex_matcher table
--- @param number_sign_width integer
function Translator.new(window_id, matcher, regex_matcher, number_sign_width)
  local config = vim.api.nvim_win_get_config(window_id)
  local row_offset, col_offset = windowlib.one_side_border_offsets(config)

  local position = vim.api.nvim_win_get_position(window_id)
  local tbl = {
    _window_id = window_id,
    _row = position[1] + row_offset - 1,
    _column = position[2] + col_offset + number_sign_width,
    _zindex = config.zindex or -1,
    _matcher = matcher,
    _regex_matcher = regex_matcher,
  }
  return setmetatable(tbl, Translator)
end

function Translator.to_targets_from_str(self, str, row, start_column, pattern)
  local targets = {}
  local column_offset = start_column
  local display_row = row + self._row
  repeat
    local matched, s, e = self._matcher:match(str, pattern, column_offset)
    if not matched then
      break
    end
    local display_column = vim.fn.strdisplaywidth(str:sub(1, s)) + self._column
    local target = Target.new(self._window_id, row, s, e, display_row, display_column, self._zindex, matched)
    table.insert(targets, target)
    column_offset = target.column_end
  until matched == nil
  return targets
end

function Translator.to_targets_from_position(self, str, row, column)
  local display_row = row + self._row
  local matched, s, e = self._regex_matcher:match(str, ".", column)
  if matched then
    local display_column = s + self._column
    return {
      Target.new(self._window_id, row, s, e, display_row, display_column, self._zindex, matched),
    }
  end
  -- NOTE: for empty line
  return { Target.new_virtual(self._window_id, row, 0, display_row, self._column, self._zindex, " ") }
end

return Translator
