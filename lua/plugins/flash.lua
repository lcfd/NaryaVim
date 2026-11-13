return {
  {
    -- Jump anywhere on screen with search labels
    "folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
    opts = {},
    -- stylua: ignore
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "[Flash] Jump." },
      -- not in visual mode: `S` there is nvim-surround's visual surround
      { "S", mode = { "n", "o" }, function() require("flash").treesitter() end, desc = "[Flash] Treesitter selection." },
      { "r", mode = "o", function() require("flash").remote() end, desc = "[Flash] Remote." },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "[Flash] Treesitter search." },
      { "<C-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "[Flash] Toggle in / search." },
    },
  },
}
