return {
  {
    "ggandor/leap.nvim",
    keys = {
      { "s", mode = { "n", "x", "o" }, desc = "Leap forward to" },
      { "S", mode = { "n", "x", "o" }, desc = "Leap backward to" },
      { "gs", mode = { "n", "x", "o" }, desc = "Leap from windows" },
    },
    config = function(_, opts)
      local leap = require("leap")
      for k, v in pairs(opts) do
        leap.opts[k] = v
      end
      leap.add_default_mappings(true)
      vim.keymap.del({ "x", "o" }, "x")
      vim.keymap.del({ "x", "o" }, "X")
    end,
  },
  {
    "numToStr/Comment.nvim",
    lazy = false,
    config = function()
      --
      -- Usage
      --

      -- NORMAL mode
      -- `gcc` - Toggles the current line using linewise comment
      -- `gbc` - Toggles the current line using blockwise comment
      -- `[count]gcc` - Toggles the number of line given as a prefix-count using linewise
      -- `[count]gbc` - Toggles the number of line given as a prefix-count using blockwise
      -- `gc[count]{motion}` - (Op-pending) Toggles the region using linewise comment
      -- `gb[count]{motion}` - (Op-pending) Toggles the region using blockwise comment
      --
      -- VISUAL mode
      -- `gc` - Toggles the region using linewise comment
      -- `gb` - Toggles the region using blockwise comment
      --
      -- Extra
      -- NORMAL mode
      -- `gb` - Toggles the region using blockwise comment
      -- `gco` - Insert comment to the next line and enters INSERT mode
      -- `gcO` - Insert comment to the previous line and enters INSERT mode
      -- `gcA` - Insert comment to end of the current line and enters INSERT mode

      -- Examples https://github.com/numToStr/Comment.nvim#examples

      require("Comment").setup({
        toggler = {
          ---Line-comment toggle keymap
          line = "gcc",
          ---Block-comment toggle keymap
          block = "gbc",
        },
        ---LHS of operator-pending mappings in NORMAL and VISUAL mode
        opleader = {
          ---Line-comment keymap
          line = "gc",
          ---Block-comment keymap
          block = "gb",
        },
        ---Add a space b/w comment and the line
        padding = true,
        ---Whether the cursor should stay at its position
        sticky = true,

        extra = {
          ---Add comment on the line above
          above = "gcO",
          ---Add comment on the line below
          below = "gco",
          ---Add comment at the end of line
          eol = "gcA",
        },
        mappings = {
          ---Operator-pending mapping; `gcc` `gbc` `gc[count]{motion}` `gb[count]{motion}`
          basic = true,
          ---Extra mapping; `gco`, `gcO`, `gcA`
          extra = true,
        },
        ---Function to call before (un)comment
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup()
    end,
  },
  {
    "johmsalas/text-case.nvim",
    config = function()
      require('textcase').setup {}
    end
  },
  {
    "nanotee/zoxide.vim",
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {},
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
  },
  {
    "nvim-pack/nvim-spectre",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("spectre").setup()
    end,
  },
  {
    "ThePrimeagen/harpoon",
  },
}
