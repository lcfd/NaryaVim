return {
  {
    "nvim-neotest/neotest",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
    },
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-python"),
        },
        runner = "pytest",
        python = ".venv/bin/python",
      })
    end,
  },
  {
    "nvim-neotest/neotest-python",
  },
}
