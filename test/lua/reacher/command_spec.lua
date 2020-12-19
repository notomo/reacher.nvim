local helper = require("reacher/lib/testlib/helper")
local command = helper.command

describe("Reacher", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can search word by one char", function()
    helper.set_lines([[
hoge foo
]])

    command("Reacher")
    assert.window_count(3)

    helper.input("f")
    command("Reacher finish")

    assert.cursor_word("foo")
  end)

  it("can search word by two words", function()
    helper.set_lines([[
hogea foo
hogeb bar
]])

    command("Reacher")

    helper.input("hoge")
    helper.input(" bar")
    command("Reacher finish")

    assert.cursor_word("hogeb")
  end)

  it("moves to the nearest", function()
    helper.set_lines([[
              hogea hogeb




hogec
]])

    command("normal! j")
    command("Reacher")

    helper.input("h")
    command("Reacher finish")

    assert.cursor_word("hogea")
  end)

  it("filters with ignorecase", function()
    helper.set_lines([[
foo
Hoge
]])

    command("Reacher")

    helper.input("h")
    command("Reacher finish")

    assert.cursor_word("Hoge")
  end)

  it("can move the cursor to the next match", function()
    helper.set_lines([[
    hogea
    hogeb
    hogec
]])

    command("Reacher")
    command("Reacher next")
    command("Reacher finish")

    assert.cursor_word("hogeb")
  end)

  it("can move the cursor to the wrapped next match", function()
    helper.set_lines([[
    hogea
    hogeb
    hogec
]])

    command("Reacher")
    command("Reacher next")
    command("Reacher next")
    command("Reacher finish")

    assert.cursor_word("hogec")

    command("Reacher")
    command("Reacher next")
    command("Reacher finish")

    assert.cursor_word("hogea")
  end)

  it("can move the cursor to the prev match", function()
    helper.set_lines([[
    hogea
    hogeb
    hogec
]])

    command("Reacher")
    command("Reacher next")
    command("Reacher finish")

    assert.cursor_word("hogeb")

    command("Reacher")
    command("Reacher prev")
    command("Reacher finish")

    assert.cursor_word("hogea")
  end)

  it("can move the cursor to the wrapped prev match", function()
    helper.set_lines([[
    hogea
    hogeb
    hogec
]])

    command("Reacher")
    command("Reacher prev")
    command("Reacher finish")

    assert.cursor_word("hogec")
  end)

  it("can move the cursor to the first match", function()
    helper.set_lines([[
    hogea
    hogeb
    hogec
]])

    command("Reacher")
    command("Reacher next")
    command("Reacher next")
    command("Reacher finish")

    assert.cursor_word("hogec")

    command("Reacher")
    command("Reacher first")
    command("Reacher finish")

    assert.cursor_word("hogea")
  end)

  it("can move the cursor to the last match", function()
    helper.set_lines([[
    hogea
    hogeb
    hogec
]])

    command("Reacher")
    command("Reacher last")
    command("Reacher finish")

    assert.cursor_word("hogec")
  end)

  it("show error if no targets", function()
    assert.error_message("no targets", function()
      command("Reacher")
    end)
  end)

  it("cannot open the multiple", function()
    helper.set_lines([[
hogea
hogeb
]])

    command("Reacher")

    helper.input("h")
    assert.window_count(3)

    command("Reacher")

    assert.window_count(3)
  end)

  it("`finish` does nothing if there is no targets", function()
    helper.set_lines([[
hoge
foo
]])
    helper.search("foo")

    command("Reacher")

    helper.input("hogea")
    assert.window_count(3)

    command("Reacher finish")

    assert.window_count(1)
    assert.cursor_word("foo")
  end)

  it("ignores inputting space", function()
    helper.set_lines([[
hoge
foo1
foo2
]])
    command("Reacher")

    helper.input("f")
    command("Reacher next")
    helper.input(" ")
    command("Reacher finish")

    assert.cursor_word("foo2")
  end)

end)
