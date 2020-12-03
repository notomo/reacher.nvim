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

    helper.sync_input("h")

    assert.cursor_word("hoge")
  end)

  it("can search word by chars", function()
    helper.set_lines([[
hogea hogeb
]])

    command("Reacher")

    helper.sync_input("hoge")
    assert.window_count(3)

    helper.sync_input("b")

    assert.cursor_word("hogeb")
  end)

end)
