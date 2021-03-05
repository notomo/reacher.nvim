local helper = require("reacher.lib.testlib.helper")
local reacher = require("reacher")

describe("reacher.nvim line source", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can search all line", function()
    helper.set_lines([[
foo
hoge
bar
]])

    reacher.start("line")

    helper.input("ar")
    reacher.finish()

    assert.current_line("bar")
    assert.column(1)
  end)

end)
