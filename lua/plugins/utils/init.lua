return {
  {
    "numToStr/Comment.nvim",
    lazy = false,
    config = function()
      -- Examples https://github.com/numToStr/Comment.nvim#examples
      local comment = require("Comment")

      if comment then
        comment.setup({
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
          -- pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
        })
      end
    end,
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
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
      local spectre = require("spectre")
      if spectre then
        spectre.setup()
      end
    end,
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
    config = function()
      local illuminate = require("illuminate")

      if illuminate then
        illuminate.configure({
          delay = 200,
          large_file_cutoff = 2000,
          large_file_overrides = {
            providers = {
              "lsp",
            },
          },
        })
      end
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
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {
      open_mapping = [[<c-\>]],
      direction = "float",
      border = "curved",
    },
  },
  {
    "folke/todo-comments.nvim",
    -- cmd = { "TodoTrouble", "TodoTelescope" },
    cmd = { "TodoTrouble" },
    event = { "BufReadPost", "BufNewFile" },
    config = true,
    -- stylua: ignore
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "[TodoComments] Next [TODO]." },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "[TodoComments] Previous [TODO]." },
      -- { "<leader>ft", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",    desc = "[Telescope] Todo/Fix/Fixme." },
    },
  },
}
