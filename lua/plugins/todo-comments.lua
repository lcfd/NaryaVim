return {
  "folke/todo-comments.nvim",
  cmd = { "TodoTrouble", "TodoTelescope" },
  event = { "BufReadPost", "BufNewFile" },
  config = true,
  -- stylua: ignore
  keys = {
    { "]t", function() require("todo-comments").jump_next() end, desc = "Next [TODO] comment" },
    { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous [TODO] comment" },
    { "<leader>ft", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Telescope — Todo/Fix/Fixme" },
  },
}
