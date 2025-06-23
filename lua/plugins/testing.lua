local safe_import = require("utils.safe_import")

return {
  {
    "nvim-neotest/neotest",
    lazy = true,
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-python",
    },
    config = function()
      local neotest = safe_import("neotest")
      local neotest_python = safe_import("neotest-python")

      if neotest and neotest_python then
        local venv_python = vim.fn.getcwd() .. ".venv/bin/python"


        local setup = {
          adapters = { neotest_python },
          runner = "pytest",
          python = venv_python,
        }

        neotest.setup(setup)
      end
    end,
  },
}
