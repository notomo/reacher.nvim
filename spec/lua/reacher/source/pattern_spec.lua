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

  it("has the current position target on init", function()
    helper.set_lines([[
foo
hoge
]])
    helper.search("hoge")
    vim.cmd("normal! $")

    reacher.start("pattern")
    reacher.finish()

    assert.current_line("hoge")
    assert.column(4)
  end)

  it("does not have current position target if it is in row range", function()
    helper.set_lines([[
hoge_a
hoge_b
bar
]])

    reacher.start("pattern", {first_row = vim.fn.line(".") + 1})
    helper.input("hoge")
    reacher.finish()

    assert.current_line("hoge_b")
  end)

end)
