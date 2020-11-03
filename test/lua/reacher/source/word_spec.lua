local helper = require("reacher/lib/testlib/helper")
local command = helper.command

describe("word source", function()

  before_each(helper.before_each)
  after_each(helper.after_each)

  it("can search word", function()
    command("Reacher")
  end)

end)
