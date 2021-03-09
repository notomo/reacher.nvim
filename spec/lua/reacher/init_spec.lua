local helper = require("reacher.lib.testlib.helper")
local reacher = require("reacher")

describe("reacher.nvim", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("moves to the nearest", function()
    helper.set_lines([[
              hogea hogeb




hogec
]])

    vim.cmd("normal! j")
    reacher.start("word")

    helper.input("h")
    reacher.finish()

    assert.cursor_word("hogea")
  end)

  it("can move the cursor to the next match", function()
    helper.set_lines([[
    hogea
    hogeb
    hogec
]])

    reacher.start("word")
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

    reacher.start("word")
    reacher.next()
    reacher.next()
    reacher.finish()

    assert.cursor_word("hogec")

    reacher.start("word")
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

    reacher.start("word")
    reacher.next()
    reacher.finish()

    assert.cursor_word("hogeb")

    reacher.start("word")
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

    reacher.start("word")
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

    reacher.start("word")
    reacher.next()
    reacher.next()
    reacher.finish()

    assert.cursor_word("hogec")

    reacher.start("word")
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

    reacher.start("word")
    reacher.last()
    reacher.finish()

    assert.cursor_word("hogec")
  end)

  it("shows error if no source", function()
    reacher.start("invalid")
    assert.exists_message("not found source: invalid")
  end)

  it("shows error if it is not started on moving", function()
    reacher.first()
    assert.exists_message("is not started")
  end)

  it("shows error if it is not started on finishing", function()
    reacher.finish()
    assert.exists_message("is not started")
  end)

  it("shows error if there is no range", function()
    helper.set_lines([[
hoge
]])

    reacher.start("word", {last_row = -1})
    assert.exists_message("no range")
  end)

  it("cannot open the multiple", function()
    helper.set_lines([[
hogea
hogeb
]])

    reacher.start("word")

    helper.input("h")
    assert.window_count(3)

    reacher.start("word")

    assert.window_count(3)
  end)

  it("`finish` does nothing if there is no targets", function()
    helper.set_lines([[
hoge
foo
]])
    helper.search("foo")

    reacher.start("word")

    helper.input("hogea")
    assert.window_count(3)

    reacher.finish()

    assert.window_count(1)
    assert.cursor_word("foo")
  end)

  it("can cancel", function()
    helper.set_lines([[
hoge
foo1
foo2
]])
    reacher.start("word")
    helper.input("foo")

    reacher.cancel()

    assert.cursor_word("hoge")
  end)

  it("ignores folded texts", function()
    helper.set_lines([[
foo
hoge1
hoge2
hoge3
hoge4
]])
    vim.cmd("2,4fold")
    vim.wo.foldenable = true

    reacher.start("word")
    helper.input("hoge")
    reacher.finish()

    assert.current_line("hoge4")
  end)

  it("shows diff fillers", function()
    vim.bo.buftype = "nofile"
    helper.set_lines([[
hoge
hoge1
hoge2
foo
foo1
foo2
foo3
bar
]])
    vim.bo.buftype = "nofile"
    vim.cmd("diffthis")

    vim.cmd("vnew")
    helper.set_lines([[
hoge
foo
bar
]])
    vim.bo.buftype = "nofile"
    vim.cmd("diffthis")

    reacher.start("word")
    helper.input("bar")
    reacher.finish()

    assert.current_line("bar")
  end)

  it("shows folded texts and diff fillers", function()
    vim.bo.buftype = "nofile"
    helper.set_lines([[
hoge
hoge1
hoge2
foo
foo1
foo2
foo3
bar
for_folded
for_folded
for_folded
for_folded
for_folded
buz_folded
buz_folded
for_folded
for_folded
for_folded
for_folded
for_folded
for_folded
]])
    vim.bo.buftype = "nofile"
    vim.cmd("diffthis")

    vim.cmd("vnew")
    helper.set_lines([[
hoge
foo
bar
for_folded
for_folded
for_folded
for_folded
for_folded
buz_folded
buz_folded
for_folded
for_folded
for_folded
for_folded
for_folded
for_folded
buz
]])
    vim.bo.buftype = "nofile"
    vim.cmd("diffthis")

    reacher.start("word")
    helper.input("buz")
    reacher.finish()

    assert.current_line("buz")
  end)

  it("removes extra input lines", function()
    helper.set_lines([[
foo
foo
hoge
]])

    reacher.start("word")
    helper.input([[
hoge
foo
]])

    local ok = vim.wait(1000, function()
      return vim.fn.line("$") == 1
    end)
    assert.is_true(ok)

    reacher.finish()

    assert.current_line("hoge")
  end)

  it("shows concealed texts", function()
    vim.wo.conceallevel = 3
    vim.wo.concealcursor = "nvic"
    vim.cmd([[syntax match testHoge "|hoge|" conceal]])
    vim.cmd([[syntax match testHoge "(hogehoge)" conceal]])

    helper.set_lines([[
foo |hoge| bar (hogehoge)
]])

    reacher.start("word")
    helper.input("bar")
    reacher.finish()

    assert.cursor_word("bar")
    assert.column(12)
  end)

  it("can show with multibyte", function()
    vim.wo.wrap = false
    helper.set_lines([[
あああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああhoge foo bar]])
    vim.cmd("normal! $")

    reacher.start("word")

    helper.input("hoge")
    reacher.finish()

    assert.cursor_word("hoge")
  end)

  it("shows jump info message", function()
    helper.set_lines([[

  hoge
]])

    reacher.start("word")
    reacher.finish()

    -- NOTE: no stopinsert offset
    assert.exists_message("jumped to %(2, 2%)")
  end)

  it("shows cancel message", function()
    helper.set_lines([[
hoge
]])

    reacher.start("word")
    reacher.cancel()

    assert.exists_message("canceled")
  end)

  it("can change matcher by option", function()
    helper.set_lines([[
foo
hoge
]])

    reacher.start("word", {source_opts = {matcher_opts = {method_name = "partial"}}})
    helper.input("ge")
    reacher.finish()

    assert.column(1)
    assert.cursor_word("hoge")
  end)

  it("can limit row range", function()
    helper.set_lines([[
foo hoge_a hoge_b
hoge
]])

    reacher.start("pattern", {first_row = vim.fn.line("."), last_row = vim.fn.line(".")})
    helper.input("ge")
    reacher.next()
    reacher.next()
    reacher.finish()

    assert.cursor_word("hoge_a")
    assert.current_line("foo hoge_a hoge_b")
  end)

  it("can pass input", function()
    helper.set_lines([[
foo
hoge_a
hoge_b
]])

    reacher.start("pattern", {input = "hoge"})
    helper.input("_b")
    reacher.finish()

    assert.cursor_word("hoge_b")
  end)

  it("trims multiline input", function()
    helper.set_lines([[
foo
hoge
]])

    reacher.start("pattern", {
      input = [[
hoge
foo
]],
    })
    reacher.finish()

    assert.cursor_word("hoge")
  end)

  it("adds search history on finish", function()
    helper.set_lines([[
foo
history_a
history_b
]])

    reacher.start("word")
    helper.input("history")
    reacher.finish()

    assert.equals("history", vim.fn.histget("/"))
  end)

  it("set search register on finish", function()
    helper.set_lines([[
foo
register_a
register_b
]])

    reacher.start("word")
    helper.input("register")
    reacher.finish()
    vim.cmd("silent! normal! n")

    assert.cursor_word("register_b")
  end)

  it("can recall backward history", function()
    helper.set_lines([[
hoge
foo
]])

    reacher.start("word")
    helper.input("foo")
    reacher.finish()
    vim.cmd("normal! gg")

    reacher.start("word")
    reacher.backward_history()
    reacher.finish()

    assert.cursor_word("foo")
  end)

  it("can recall forward history", function()
    helper.set_lines([[
hoge
foo
bar
]])

    reacher.start("word")
    helper.input("foo")
    reacher.finish()

    reacher.start("word")
    helper.input("bar")
    reacher.finish()
    vim.cmd("normal! gg")

    reacher.start("word")
    reacher.backward_history()
    reacher.backward_history()
    reacher.forward_history()
    reacher.finish()

    assert.cursor_word("bar")
  end)

end)
