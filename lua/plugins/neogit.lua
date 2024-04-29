return {
  {
    "TimUntersberger/neogit",
    dependencies = "nvim-lua/plenary.nvim",
    config = function(_, opts)
      require("neogit").setup({
        commit_popup = {
          kind = "split",
        },
      })
    end,
  },
}
