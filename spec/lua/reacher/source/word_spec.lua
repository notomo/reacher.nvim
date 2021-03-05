local helper = require("reacher.lib.testlib.helper")
local reacher = require("reacher")

describe("reacher.nvim word source", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can search word by char", function()
    helper.set_lines([[
hoge foo
]])

    reacher.start("word")

    helper.input("f")
    reacher.finish()

    assert.cursor_word("foo")
  end)

  it("shows only words as targets", function()
    helper.set_lines([[
hoge foo
hoge bar
]])

    reacher.start("word")

    reacher.next()
    reacher.next()
    reacher.next()
    reacher.finish()

    assert.cursor_word("bar")
  end)

  it("shows error if no targets", function()
    reacher.start("word")
    assert.exists_message("no targets")
  end)

end)
