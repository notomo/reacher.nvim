local helper = require("reacher.test.helper")
local reacher = helper.require("reacher")
local assert = helper.typed_assert(assert)

describe("reacher.next()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("moves the cursor to the next match", function()
    helper.set_lines([[
    hoge_a
    hoge_b
    hoge_c
]])

    reacher.start({ input = "hoge" })
    reacher.next()
    reacher.finish()

    assert.cursor_word("hoge_b")
  end)

  it("moves the cursor to the wrapped next match", function()
    helper.set_lines([[
    hoge_a
    hoge_b
    hoge_c
]])
    helper.search("hoge_c")

    reacher.start({ input = "hoge" })
    reacher.next()
    reacher.finish()

    assert.cursor_word("hoge_a")
  end)
end)

describe("reacher.previous()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("moves the cursor to the previous match", function()
    helper.set_lines([[
    hoge_a
    hoge_b
    hoge_c
]])
    helper.search("hoge_b")

    reacher.start({ input = "hoge" })
    reacher.previous()
    reacher.finish()

    assert.cursor_word("hoge_a")
  end)

  it("moves the cursor to the wrapped previous match", function()
    helper.set_lines([[
    hoge_a
    hoge_b
    hoge_c
]])

    reacher.start({ input = "hoge" })
    reacher.previous()
    reacher.finish()

    assert.cursor_word("hoge_c")
  end)
end)

describe("reacher.first()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("moves the cursor to the first match", function()
    helper.set_lines([[
    hoge_a
    hoge_b
    hoge_c
]])
    helper.search("hoge_c")

    reacher.start({ input = "hoge" })
    reacher.first()
    reacher.finish()

    assert.cursor_word("hoge_a")
  end)

  it("shows error if it is not started on moving", function()
    local ok, err = pcall(function()
      reacher.first()
    end)
    assert.is_false(ok)
    assert.match("is not started", err)
  end)
end)

describe("reacher.last()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("moves the cursor to the last match", function()
    helper.set_lines([[
    hoge_a
    hoge_b
    hoge_c
]])

    reacher.start({ input = "hoge" })
    reacher.last()
    reacher.finish()

    assert.cursor_word("hoge_c")
  end)
end)

describe("reacher.side_first()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("moves the cursor to the first column match", function()
    helper.set_lines([[
        hoge_a
          hoge_b
  hoge_c
      hoge_d
]])

    reacher.start({ input = "hoge" })
    reacher.side_first()
    reacher.finish()

    assert.cursor_word("hoge_c")
  end)
end)

describe("reacher.side_last()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("moves the cursor to the last column match", function()
    helper.set_lines([[
        hoge_a
		      hoge_b
					hoge_c
  hoge_d
      hoge_e
]])

    reacher.start({ input = "hoge" })
    reacher.side_last()
    reacher.finish()

    assert.cursor_word("hoge_c")
  end)
end)

describe("reacher.side_next()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("moves the cursor to the next side match", function()
    helper.set_lines([[
hoge_a
hoge_b
    hoge_c
  hoge_d
      hoge_e
]])

    reacher.start({ input = "hoge" })
    reacher.side_next()
    reacher.side_next()
    reacher.finish()

    assert.cursor_word("hoge_d")
  end)

  it("moves the cursor to the wrapped next side match", function()
    helper.set_lines([[
hoge_a
          hoge_b
  hoge_c
      hoge_d
]])
    helper.search("hoge_b")

    reacher.start({ input = "hoge" })
    reacher.side_next()
    reacher.finish()

    assert.cursor_word("hoge_a")
  end)
end)

describe("reacher.side_previous()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("moves the cursor to the previous side match", function()
    helper.set_lines([[
hoge_a
hoge_b
    hoge_c
  hoge_d
      hoge_e
]])
    helper.search("hoge_d")

    reacher.start({ input = "hoge" })
    reacher.side_previous()
    reacher.side_previous()
    reacher.finish()

    assert.cursor_word("hoge_a")
  end)

  it("moves the cursor to the wrapped previous side match", function()
    helper.set_lines([[
hoge_a
          hoge_b
  hoge_c
      hoge_d
]])

    reacher.start({ input = "hoge" })
    reacher.side_previous()
    reacher.finish()

    assert.cursor_word("hoge_b")
  end)
end)

describe("reacher.cancel()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("cancels", function()
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

  it("shows cancel message", function()
    helper.set_lines([[
hoge
]])

    reacher.start()
    reacher.cancel()

    assert.exists_message("canceled")
  end)

  it("adds search history", function()
    reacher.start()
    helper.input("cancel_history")
    reacher.cancel()

    assert.equal("cancel_history", vim.fn.histget("/"))
  end)

  it("can go back to visual mode", function()
    helper.set_lines([[
hoge
foo
]])

    vim.cmd.normal({ args = { "v" }, bang = true })
    vim.cmd.normal({ args = { "$" }, bang = true })
    reacher.start({ input = "foo" })
    reacher.cancel()

    assert.mode("v")
    assert.restored_visual(true)
    assert.current_line("hoge")
  end)
end)

describe("reacher.forward_history()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("recalls forward history", function()
    helper.set_lines([[
hoge
foo
bar
]])

    reacher.start()
    helper.input("foo")
    reacher.finish()

    reacher.start()
    helper.input("bar")
    reacher.finish()
    vim.cmd.normal({ args = { "gg" }, bang = true })

    reacher.start()
    reacher.backward_history()
    reacher.backward_history()
    reacher.forward_history()
    reacher.finish()

    assert.cursor_word("bar")
  end)
end)

describe("reacher.backward_history()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("recalls backward history", function()
    helper.set_lines([[
hoge
foo
]])

    reacher.start()
    helper.input("foo")
    reacher.finish()
    vim.cmd.normal({ args = { "gg" }, bang = true })

    reacher.start()
    reacher.backward_history()
    reacher.finish()

    assert.cursor_word("foo")
  end)

  it("adds search history", function()
    vim.fn.histadd("/", "already")

    reacher.start()
    helper.input("recall_history")
    reacher.backward_history()

    assert.equal("recall_history", vim.fn.histget("/"))
  end)
end)

describe("reacher.finish()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("moves the cursor to the nearest match", function()
    helper.set_lines([[
              hoge_a hoge_b




hoge_c
]])
    vim.cmd.normal({ args = { "j" }, bang = true })

    reacher.start()
    helper.input("h")
    reacher.finish()

    assert.cursor_word("hoge_a")
  end)

  it("adds search history", function()
    reacher.start()
    helper.input("finish_history")
    reacher.finish()

    assert.equal("finish_history", vim.fn.histget("/"))
  end)

  it("sets search register", function()
    helper.set_lines([[
foo
register_a
register_b
]])

    reacher.start()
    helper.input("register")
    reacher.finish()
    vim.cmd.normal({ args = { "n" }, bang = true, mods = { silent = true, emsg_silent = true } })

    assert.cursor_word("register_b")
  end)

  it("shows error if it is not started", function()
    local ok, err = pcall(function()
      reacher.finish()
    end)
    assert.is_false(ok)
    assert.match("is not started", err)
  end)

  it("does nothing if there is no targets", function()
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

  it("shows jump info message", function()
    helper.set_lines([[

  hoge
]])

    reacher.start({ input = "hoge" })
    reacher.finish()

    -- NOTE: no stopinsert offset
    assert.exists_message("jumped to %(2, 2%)")
  end)

  it("can go back to linewise visual mode", function()
    helper.set_lines([[
hoge
foo
]])

    vim.cmd.normal({ args = { "V" }, bang = true })
    reacher.start({ input = "foo" })
    reacher.finish()

    assert.mode("V")
    assert.current_line("foo")

    vim.cmd.normal({ args = { "o" }, bang = true })
    assert.current_line("hoge")
  end)

  it("can go back to blockwise visual mode", function()
    local ctrl_v = vim.api.nvim_eval('"\\<C-v>"')

    helper.set_lines([[
hoge
foo
]])
    helper.search("oge")
    vim.cmd.normal({ args = { ctrl_v }, bang = true })
    reacher.start({ input = "oo" })
    reacher.finish()

    assert.mode(ctrl_v)
    assert.current_line("foo")

    vim.cmd.normal({ args = { "d" }, bang = true })
    assert.current_line("hge")
  end)
end)

describe("reacher.start()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("shows the current position match", function()
    helper.set_lines([[
foo
hoge
]])
    helper.search("hoge")
    vim.cmd.normal({ args = { "$" }, bang = true })

    reacher.start()
    reacher.finish()

    assert.current_line("hoge")
    assert.cursor_column(4)
    assert.restored_visual(false)
  end)

  it("does not show the current position target if it is not in row range", function()
    helper.set_lines([[
hoge_a
hoge_b
bar
]])

    reacher.start({ first_row = vim.fn.line(".") + 1 })
    helper.input("hoge")
    reacher.finish()

    assert.current_line("hoge_b")
  end)

  it("can pass input", function()
    helper.set_lines([[
foo
hoge_a
hoge_b
]])

    reacher.start({ input = "hoge" })
    helper.input("_b")
    reacher.finish()

    assert.cursor_word("hoge_b")
  end)

  it("trims multiline input", function()
    helper.set_lines([[
foo
hoge
]])

    reacher.start({
      input = [[
hoge
foo
]],
    })
    reacher.finish()

    assert.cursor_word("hoge")
  end)

  it("can limit row range", function()
    helper.set_lines([[
foo hoge_a hoge_b
hoge
]])

    reacher.start({ first_row = vim.fn.line("."), last_row = vim.fn.line(".") })
    helper.input("ge")
    reacher.next()
    reacher.next()
    reacher.finish()

    assert.cursor_word("hoge_a")
    assert.current_line("foo hoge_a hoge_b")
  end)

  it("shows error if no matcher", function()
    local ok, err = pcall(function()
      reacher.start({ matcher_opts = { name = "invalid" } })
    end)
    assert.is_false(ok)
    assert.match("not found matcher: invalid", err)
  end)

  it("shows error if there is no range", function()
    helper.set_lines([[
hoge
]])

    local ok, err = pcall(function()
      reacher.start({ last_row = -1 })
    end)
    assert.is_false(ok)
    assert.match("no range", err)
  end)

  it("does not start multiple", function()
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

  it("shows error if `rightleft`", function()
    vim.api.nvim_set_option_value("rightleft", true, { scope = "local" })
    local ok, err = pcall(function()
      reacher.start()
    end)
    assert.is_false(ok)
    assert.match("`rightleft` is not supported", err)
  end)

  it("shows error if opts is invalid", function()
    local ok, err = pcall(function()
      reacher.start("invalid_opts")
    end)
    assert.is_false(ok)
    assert.match([[opts: expected table, got string: "invalid_opts"]], err)
  end)
end)

describe("reacher.start_multiple()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("shows matches in the all windows", function()
    helper.set_lines([[

hoge
]])

    vim.cmd.vnew()
    helper.set_lines([[
foo
]])

    reacher.start_multiple()
    helper.input("hoge")
    reacher.finish()

    assert.current_line("hoge")
  end)

  it("stops visual mode if target buffer is different from current buffer", function()
    helper.set_lines([[

hoge
]])

    vim.cmd.vnew()
    helper.set_lines([[
foo
]])

    vim.cmd.normal({ args = { "v" }, bang = true })
    reacher.start_multiple()
    helper.input("hoge")
    reacher.finish()

    assert.mode("n")
  end)

  it("can mask targets by floating windows", function()
    helper.set_lines([[
foo
hoge
]])

    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_open_win(bufnr, false, {
      width = 10,
      height = 10,
      relative = "editor",
      row = 0,
      col = 0,
      style = "minimal",
    })
    reacher.start_multiple()
    helper.input("hoge")
    reacher.finish()

    assert.current_line("foo")
  end)
end)

describe("reacher.again()", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("reproduces the last call options", function()
    helper.set_lines([[
hoge foo bar
bar
]])

    reacher.start({ first_row = vim.fn.line("."), last_row = vim.fn.line(".") })
    reacher.cancel()

    vim.cmd.normal({ args = { "j" }, bang = true })
    reacher.again()
    helper.input("bar")
    reacher.finish()

    assert.current_line("hoge foo bar")
  end)

  it("executes the same with the last called", function()
    helper.set_lines([[

hoge
]])

    vim.cmd.vnew()
    helper.set_lines([[
foo
]])

    reacher.start_multiple()
    reacher.cancel()

    reacher.again()
    helper.input("hoge")
    reacher.finish()

    assert.current_line("hoge")
  end)
end)

describe("reacher.nvim inputter", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("removes extra lines", function()
    helper.set_lines([[
foo
foo
hoge
]])

    reacher.start()
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

  it("recognizes smartcase option", function()
    helper.set_lines([[
foo
hoge
Hoge
]])
    vim.o.ignorecase = true
    vim.o.smartcase = true

    reacher.start({ input = "Hoge" })
    reacher.finish()

    assert.current_line("Hoge")
  end)

  it("is closed on leaving", function()
    reacher.start({})
    vim.cmd.wincmd("w")

    assert.window_count(1)
  end)
end)

describe("reacher.nvim view", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  it("ignores folded texts", function()
    helper.set_lines([[
foo
hoge1
hoge2
hoge3
hoge4
]])
    vim.cmd.fold({ range = { 2, 4 } })
    vim.wo.foldenable = true

    reacher.start()
    helper.input("hoge")
    reacher.finish()

    assert.current_line("hoge4")
  end)

  it("shows diff fillers as empty line", function()
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
    vim.cmd.diffthis()

    vim.cmd.vnew()
    helper.set_lines([[
hoge
foo
bar
]])
    vim.bo.buftype = "nofile"
    vim.cmd.diffthis()

    reacher.start()
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
    vim.cmd.diffthis()

    vim.cmd.vnew()
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
    vim.cmd.diffthis()

    reacher.start()
    helper.input("buz")
    reacher.finish()

    assert.current_line("buz")
  end)

  it("ignores diff fillers above the first row", function()
    vim.bo.buftype = "nofile"
    helper.set_lines(vim.fn["repeat"]("deleted\n", 50) .. [[
hoge
foo
bar
]])
    vim.bo.buftype = "nofile"
    vim.cmd.diffthis()

    vim.cmd.vnew()
    helper.set_lines([[
hoge
foo
bar
]])
    vim.bo.buftype = "nofile"
    vim.cmd.diffthis()
    vim.cmd.normal({ args = { "G" }, bang = true })
    vim.cmd.normal({ args = { "gg" }, bang = true })

    reacher.start()
    helper.input("bar")
    reacher.finish()

    assert.current_line("bar")
  end)

  it("shows concealed texts", function()
    vim.wo.conceallevel = 3
    vim.wo.concealcursor = "nvic"
    vim.cmd.syntax({ args = { "match", "testHoge", '"|hoge|"', "conceal" } })
    vim.cmd.syntax({ args = { "match", "testHoge", '"(hogehoge)"', "conceal" } })

    helper.set_lines([[
foo |hoge| bar (hogehoge)
]])

    reacher.start()
    helper.input("bar")
    reacher.finish()

    assert.cursor_word("bar")
    assert.cursor_column(12)
  end)

  it("can show with multibyte", function()
    vim.wo.wrap = false
    helper.set_lines(
      [[
あああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああああhoge foo bar]]
    )
    vim.cmd.normal({ args = { "$" }, bang = true })

    reacher.start()

    helper.input("hoge")
    reacher.finish()

    assert.cursor_word("hoge")
  end)

  it("can show with virt_lines", function()
    helper.set_lines([[
hoge_a
hoge_b
hoge_c]])
    local bufnr = vim.api.nvim_get_current_buf()
    local ns = vim.api.nvim_create_namespace("test")
    vim.api.nvim_buf_set_extmark(bufnr, ns, 0, 0, {
      virt_lines = vim.fn["repeat"]({ { { "virtual" } } }, vim.o.lines),
    })
    vim.cmd.normal({ args = { "G" }, bang = true })
    vim.cmd.redraw() -- HACK

    reacher.start()

    helper.input("hoge_b")
    reacher.finish()

    assert.cursor_word("hoge_b")
  end)
end)
