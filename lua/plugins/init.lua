return {
  -- {
  --   "mickael-menu/zk-nvim",
  --   config = function()
  --     require("zk").setup({
  --       picker = "telescope",
  --     })
  --   end,
  -- },
  {
    "folke/zen-mode.nvim",
    opts = {},
  },
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = { "BufReadPost", "BufNewFile" },
    config = true,
    -- stylua: ignore
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "[TodoComments] Next [TODO]." },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "[TodoComments] Previous [TODO]." },
      { "<leader>ft", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "[Telescope] Todo/Fix/Fixme." },
    },
  },
}
