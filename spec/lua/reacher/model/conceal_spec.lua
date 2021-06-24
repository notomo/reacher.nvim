local helper = require("reacher.lib.testlib.helper")

describe("reacher.model.conceal", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  for _, c in ipairs({
    {expected = "", line = "", cmd = [[]], level = 3},
    {
      expected = "",
      line = "|hoge|",
      cmd = [[syntax match reacherTestSyntax "|hoge|" conceal]],
      level = 3,
    },
    {
      expected = "&",
      line = "|hoge|",
      cmd = [[syntax match reacherTestSyntax "|hoge|" conceal cchar=&]],
      level = 2,
    },
    {
      expected = "",
      line = "|hoge|",
      cmd = [[syntax match reacherTestSyntax "|hoge|" conceal cchar=&]],
      level = 3,
    },
    {
      expected = "hogeあhoge",
      line = "hogeほげhoge",
      cmd = [[syntax match reacherTestSyntax "ほげ" conceal cchar=あ]],
      level = 2,
    },
    {
      expected = "|hoge|",
      line = "|hoge|",
      cmd = [[syntax match reacherTestSyntax "|hoge|" conceal cchar=&]],
      level = 3,
      disable = true,
    },
  }) do
    it(("`%s` = `%s`, conceallevel = %d , disable = %s"):format(c.line, c.expected, c.level, c.disable), function()
      vim.wo.concealcursor = "nvic"
      vim.wo.conceallevel = c.level
      vim.cmd(c.cmd)
      helper.set_lines(c.line)

      local window_id = vim.api.nvim_get_current_win()
      local row = 1
      local conceal_line = require("reacher.model.conceal").ConcealLine.new(window_id, row, c.disable)
      assert.equals(c.expected, conceal_line.str)
    end)
  end

end)
