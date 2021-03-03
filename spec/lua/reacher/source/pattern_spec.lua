local helper = require("reacher.lib.testlib.helper")
local reacher = require("reacher")

describe("reacher.nvim pattern source", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can search by pattern", function()
    helper.set_lines([[
foo
hoge
]])

    reacher.start("pattern")

    helper.input("ge")
    reacher.finish()

    assert.current_line("hoge")
    assert.column(3)
  end)

end)
