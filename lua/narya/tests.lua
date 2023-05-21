local M = {}

function M.setup()
  require("neotest").setup({
    adapters = {
      require("neotest-python"),
    },
    runner = "pytest",
    python = ".venv/bin/python",
  })
end

return M
