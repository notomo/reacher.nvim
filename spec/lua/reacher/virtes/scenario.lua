local reacher = setmetatable({}, {
  __index = function(_, k)
    return require("reacher")[k]
  end,
})

local scenario = function(ctx)
  vim.o.termguicolors = true
  vim.o.background = "dark"
  vim.o.hlsearch = false

  vim.api.nvim_buf_set_lines(
    0,
    0,
    -1,
    false,
    vim.split(
      [[
hoge
hoge
hoge
]],
      "\n",
      { plain = true }
    )
  )

  reacher.start({ input = "hoge" })
  ctx:screenshot()

  reacher.next()
  ctx:screenshot()

  reacher.finish()
  ctx:screenshot()
end

local main = function(comparison, result_dir)
  local deploy_lua_dir = vim.fn.trim(vim.fn.system("luarocks --lua-version=5.1 config deploy_lua_dir"))
  package.path = package.path .. ";" .. deploy_lua_dir .. "/?.lua;" .. deploy_lua_dir .. "/?/init.lua"
  vim.o.runtimepath = vim.fn.getcwd() .. "," .. vim.o.runtimepath
  vim.cmd.runtime({ args = { "plugin/*.vim" }, bang = true })

  local test = require("virtes").setup({
    scenario = scenario,
    result_dir = result_dir,
    cleanup = function()
      vim.cmd.bwipeout({
        range = { 1, vim.fn.bufnr("$") },
        bang = true,
        mods = { silent = true, emsg_silent = true },
      })
      require("vusted.helper").cleanup_loaded_modules("reacher")
    end,
  })
  local before = test:run({ hash = comparison })
  before:write_replay_script()

  local after = test:run({ hash = nil })
  after:write_replay_script()

  before:diff(after):write_replay_script()
end

return main
