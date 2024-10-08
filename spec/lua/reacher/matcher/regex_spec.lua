local helper = require("reacher.test.helper")
local assert = helper.typed_assert(assert)

describe("reacher.matcher.regex", function()
  before_each(helper.before_each)
  after_each(helper.after_each)

  for _, c in ipairs({
    { str = "", expected = false },
    { str = "aaa", expected = false },
    { str = "\\S", expected = false },
    { str = "\\_S", expected = false },
    { str = "\\%V", expected = false },
    { str = "aaA", expected = true },
    { str = "A\\cA", expected = false },
    { str = "A\\CA", expected = false },
    { str = "A\\\\cA", expected = true },
    { str = "A\\\\CA", expected = true },
  }) do
    it(("has_uppercase('%s') == %s"):format(c.str, c.expected), function()
      local actual = require("reacher.matcher.regex"):has_uppercase(c.str)
      assert.equal(c.expected, actual)
    end)
  end

  for _, c in ipairs({
    { str = "aaa", smartcase = true, expected = "aaa" },
    { str = "aaA", smartcase = true, expected = "\\CaaA" },
    { str = "A\\C", smartcase = true, expected = "A\\C" },
    { str = "A\\c", smartcase = true, expected = "A\\c" },
    { str = "A\\\\C", smartcase = true, expected = "\\CA\\\\C" },
    { str = "A\\\\c", smartcase = true, expected = "\\CA\\\\c" },
    { str = "A", smartcase = false, expected = "A" },
  }) do
    it(("adjust_case('%s') == '%s' (smartcase == %s)"):format(c.str, c.expected, c.smartcase), function()
      local matcher = require("reacher.matcher.regex")
      matcher.smartcase = c.smartcase
      local actual = matcher:adjust_case(c.str)
      assert.equal(c.expected, actual)
    end)
  end
end)
