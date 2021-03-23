local helper = require("reacher.lib.testlib.helper")

describe("reacher.model.column_range.calc_displayed_last_line()", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  for _, c in ipairs({
    {lines = [[]], expected = nil},
    {
      lines = [[
hoge]],
      expected = nil,
    },
    {
      lines = [[
hoge
foo
bar]],
      expected = nil,
    },
    {
      lines = [[
bar
bar
bar
bar
bar
bar
bar
bar
hoge_hoge_hoge_hoge_hidden_hidden
foo]],
      expected = "hoge_hoge_hoge_hoge_",
    },
    {
      lines = [[
bar
bar
bar
bar
bar
bar
bar
hoge_hoge_hoge_hoge hoge_hoge_hoge_hoge hidden hidden
foo]],
      expected = "hoge_hoge_hoge_hoge hoge_hoge_hoge_hoge ",
    },
    {
      height = 8,
      topline = 2,
      lines = [[
hidden
bar
bar
bar
bar
bar
bar
hoge_hoge_hoge_hoge hoge_hoge_hoge_hoge
hidden
hidden
hidden
hidden
hidden
hidden
hidden]],
      expected = nil,
    },
  }) do
    it(("last_line == `%s` if lines == \n%s"):format(c.expected, c.lines), function()
      vim.wo.wrap = true
      vim.o.lines = (c.height or 9) + 1 + 1 -- statusline, commandline
      vim.o.columns = 20
      helper.set_lines(c.lines)
      vim.fn.winrestview({lnum = c.topline or 1, topline = c.topline or 1})

      local line = require("reacher.model.column_range").calc_displayed_last_line()

      assert.equals(c.expected, line)
    end)
  end

end)
