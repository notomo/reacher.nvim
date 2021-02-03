local helper = require("reacher.lib.testlib.helper")

describe("Reacher", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can search word by one char", function()
    helper.set_lines([[
hoge foo
]])

    vim.cmd("Reacher")
    assert.window_count(3)

    helper.input("f")
    vim.cmd("Reacher finish")

    assert.cursor_word("foo")
  end)

  it("can search word by two words", function()
    helper.set_lines([[
hogea foo
hogeb bar
]])

    vim.cmd("Reacher")

    helper.input("hoge")
    helper.input(" bar")
    vim.cmd("Reacher finish")

    assert.cursor_word("hogeb")
  end)

  it("moves to the nearest", function()
    helper.set_lines([[
              hogea hogeb




hogec
]])

    vim.cmd("normal! j")
    vim.cmd("Reacher")

    helper.input("h")
    vim.cmd("Reacher finish")

    assert.cursor_word("hogea")
  end)

  it("filters with ignorecase", function()
    helper.set_lines([[
foo
Hoge
]])

    vim.cmd("Reacher")

    helper.input("h")
    vim.cmd("Reacher finish")

    assert.cursor_word("Hoge")
  end)

  it("can move the cursor to the next match", function()
    helper.set_lines([[
    hogea
    hogeb
    hogec
]])

    vim.cmd("Reacher")
    vim.cmd("Reacher next")
    vim.cmd("Reacher finish")

    assert.cursor_word("hogeb")
  end)

  it("can move the cursor to the wrapped next match", function()
    helper.set_lines([[
    hogea
    hogeb
    hogec
]])

    vim.cmd("Reacher")
    vim.cmd("Reacher next")
    vim.cmd("Reacher next")
    vim.cmd("Reacher finish")

    assert.cursor_word("hogec")

    vim.cmd("Reacher")
    vim.cmd("Reacher next")
    vim.cmd("Reacher finish")

    assert.cursor_word("hogea")
  end)

  it("can move the cursor to the prev match", function()
    helper.set_lines([[
    hogea
    hogeb
    hogec
]])

    vim.cmd("Reacher")
    vim.cmd("Reacher next")
    vim.cmd("Reacher finish")

    assert.cursor_word("hogeb")

    vim.cmd("Reacher")
    vim.cmd("Reacher prev")
    vim.cmd("Reacher finish")

    assert.cursor_word("hogea")
  end)

  it("can move the cursor to the wrapped prev match", function()
    helper.set_lines([[
    hogea
    hogeb
    hogec
]])

    vim.cmd("Reacher")
    vim.cmd("Reacher prev")
    vim.cmd("Reacher finish")

    assert.cursor_word("hogec")
  end)

  it("can move the cursor to the first match", function()
    helper.set_lines([[
    hogea
    hogeb
    hogec
]])

    vim.cmd("Reacher")
    vim.cmd("Reacher next")
    vim.cmd("Reacher next")
    vim.cmd("Reacher finish")

    assert.cursor_word("hogec")

    vim.cmd("Reacher")
    vim.cmd("Reacher first")
    vim.cmd("Reacher finish")

    assert.cursor_word("hogea")
  end)

  it("can move the cursor to the last match", function()
    helper.set_lines([[
    hogea
    hogeb
    hogec
]])

    vim.cmd("Reacher")
    vim.cmd("Reacher last")
    vim.cmd("Reacher finish")

    assert.cursor_word("hogec")
  end)

  it("show error if no targets", function()
    assert.error_message("no targets", function()
      vim.cmd("Reacher")
    end)
  end)

  it("cannot open the multiple", function()
    helper.set_lines([[
hogea
hogeb
]])

    vim.cmd("Reacher")

    helper.input("h")
    assert.window_count(3)

    vim.cmd("Reacher")

    assert.window_count(3)
  end)

  it("`finish` does nothing if there is no targets", function()
    helper.set_lines([[
hoge
foo
]])
    helper.search("foo")

    vim.cmd("Reacher")

    helper.input("hogea")
    assert.window_count(3)

    vim.cmd("Reacher finish")

    assert.window_count(1)
    assert.cursor_word("foo")
  end)

  it("ignores inputting space", function()
    helper.set_lines([[
hoge
foo1
foo2
]])
    vim.cmd("Reacher")

    helper.input("f")
    vim.cmd("Reacher next")
    helper.input(" ")
    vim.cmd("Reacher finish")

    assert.cursor_word("foo2")
  end)

end)
