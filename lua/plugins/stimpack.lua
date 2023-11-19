return {
  {
    -- Autopairs for neovim written by lua
    -- https://github.com/windwp/nvim-autopairs
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {},
  },
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
      require("nvim-surround").setup({
        keymaps = {
          insert = "<C-g>m",
          insert_line = "<C-g>M",
          normal = "ms",
          normal_cur = "mss",
          normal_line = "mS",
          normal_cur_line = "mSS",
          visual = "M",
          visual_line = "gS",
          delete = "ds",
          change = "cs",
          change_line = "cS",
        },
      })
    end,
  },
  {
    "johmsalas/text-case.nvim",
    config = function()
      require("textcase").setup({})
    end,
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
    keys = {
      { "-", "<CMD>lua require('harpoon.mark').add_file()<CR>", mode = "n" },
      { "=", "<CMD>lua require('harpoon.ui').toggle_quick_menu()<CR>", mode = "n" },
      { "<leader>1", "<CMD>lua require('harpoon.ui').nav_file(1)<CR>", mode = "n" },
      { "<leader>2", "<CMD>lua require('harpoon.ui').nav_file(2)<CR>", mode = "n" },
      { "<leader>3", "<CMD>lua require('harpoon.ui').nav_file(3)<CR>", mode = "n" },
      { "<leader>4", "<CMD>lua require('harpoon.ui').nav_file(4)<CR>", mode = "n" },
      { "<leader>5", "<CMD>lua require('harpoon.ui').nav_file(5)<CR>", mode = "n" },
    },
  },
  {
    -- Automatically highlighting other uses of the word under the cursor
    "RRethy/vim-illuminate",
    event = {
      "BufReadPost",
      "BufNewFile",
    },
    opts = {
      delay = 400,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = {
          "lsp",
        },
      },
    },
    config = function(_)
      require("illuminate").configure({
        delay = 200,
        large_file_cutoff = 2000,
        large_file_overrides = {
          providers = {
            "lsp",
          },
        },
      })
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 2000
    end,
    opts = {},
  },
}
