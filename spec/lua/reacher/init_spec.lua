local helper = require("reacher.lib.testlib.helper")
local reacher = require("reacher")

describe("reacher.nvim", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can search word by one char", function()
    helper.set_lines([[
hoge foo
]])

    reacher.start()
    assert.window_count(3)

    helper.input("f")
    reacher.finish()

    assert.cursor_word("foo")
  end)

  it("can search word by two words", function()
    helper.set_lines([[
hogea foo
hogeb bar
]])

    reacher.start()

    helper.input("hoge")
    helper.input(" bar")
    reacher.finish()

    assert.cursor_word("hogeb")
  end)

  it("moves to the nearest", function()
    helper.set_lines([[
              hogea hogeb




hogec
]])

    vim.cmd("normal! j")
    reacher.start()

    helper.input("h")
    reacher.finish()

    assert.cursor_word("hogea")
  end)

  it("filters with ignorecase", function()
    helper.set_lines([[
foo
Hoge
]])

    reacher.start()

    helper.input("h")
    reacher.finish()

    assert.cursor_word("Hoge")
  end)

  it("can move the cursor to the next match", function()
    helper.set_lines([[
    hogea
    hogeb
    hogec
]])

    reacher.start()
    reacher.next()
    reacher.finish()

    assert.cursor_word("hogeb")
  end)

  it("can move the cursor to the wrapped next match", function()
    helper.set_lines([[
    hogea
    hogeb
    hogec
]])

    reacher.start()
    reacher.next()
    reacher.next()
    reacher.finish()

    assert.cursor_word("hogec")

    reacher.start()
    reacher.next()
    reacher.finish()

    assert.cursor_word("hogea")
  end)

  it("can move the cursor to the prev match", function()
    helper.set_lines([[
    hogea
    hogeb
    hogec
]])

    reacher.start()
    reacher.next()
    reacher.finish()

    assert.cursor_word("hogeb")

    reacher.start()
    reacher.prev()
    reacher.finish()

    assert.cursor_word("hogea")
  end)

  it("can move the cursor to the wrapped prev match", function()
    helper.set_lines([[
    hogea
    hogeb
    hogec
]])

    reacher.start()
    reacher.prev()
    reacher.finish()

    assert.cursor_word("hogec")
  end)

  it("can move the cursor to the first match", function()
    helper.set_lines([[
    hogea
    hogeb
    hogec
]])

    reacher.start()
    reacher.next()
    reacher.next()
    reacher.finish()

    assert.cursor_word("hogec")

    reacher.start()
    reacher.first()
    reacher.finish()

    assert.cursor_word("hogea")
  end)

  it("can move the cursor to the last match", function()
    helper.set_lines([[
    hogea
    hogeb
    hogec
]])

    reacher.start()
    reacher.last()
    reacher.finish()

    assert.cursor_word("hogec")
  end)

  it("show error if no targets", function()
    reacher.start()
    assert.exists_message("no targets")
  end)

  it("cannot open the multiple", function()
    helper.set_lines([[
hogea
hogeb
]])

    reacher.start()

    helper.input("h")
    assert.window_count(3)

    reacher.start()

    assert.window_count(3)
  end)

  it("`finish` does nothing if there is no targets", function()
    helper.set_lines([[
hoge
foo
]])
    helper.search("foo")

    reacher.start()

    helper.input("hogea")
    assert.window_count(3)

    reacher.finish()

    assert.window_count(1)
    assert.cursor_word("foo")
  end)

  it("ignores inputting space", function()
    helper.set_lines([[
hoge
foo1
foo2
]])
    reacher.start()

    helper.input("f")
    reacher.next()
    helper.input(" ")
    reacher.finish()

    assert.cursor_word("foo2")
  end)

  it("can cancel", function()
    helper.set_lines([[
hoge
foo1
foo2
]])
    reacher.start()
    helper.input("foo")

    reacher.cancel()

    assert.cursor_word("hoge")
  end)

end)
