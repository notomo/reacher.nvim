local helper = require("reacher.lib.testlib.helper")
local reacher = require("reacher")

describe("reacher.nvim char source", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can search all char", function()
    helper.set_lines([[
foo
hoge
]])

    reacher.start("char")

    helper.input("ge")
    reacher.finish()

    assert.current_line("hoge")
    assert.column(3)
  end)

end)
