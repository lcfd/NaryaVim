local safe_import = require("utils.safe_import")

return {
  {
    "kdheepak/lazygit.nvim",
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    -- setting the keybinding for LazyGit with 'keys' is recommended in
    -- order to load the plugin when the command is run for the first time
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>", desc = "[LazyGit] Open" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      local gitsigns = safe_import("gitsigns")
      gitsigns.setup()
    end,
  },
  -- {
  --   "TimUntersberger/neogit",
  --   dependencies = "nvim-lua/plenary.nvim",
  --   config = function(_, opts)
  --     local neogit = safe_import("neogit")

  --     neogit.setup({
  --       commit_popup = {
  --         kind = "split",
  --       },
  --     })
  --   end,
  -- },
}
