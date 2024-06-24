local safe_import = require("utils.safe_import")

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
      local leap = safe_import("leap")
      local leap = safe_import("leap")

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
      local comment = safe_import("Comment")

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
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      local nvim_surround = safe_import("nvim-surround")
      -- local get_pickers = require("plugins.telescope.get_pickers")
      local sorround_mappings = require("plugins.utils.config_nvim_sorround_mappings")

      nvim_surround.setup({
        keymaps = sorround_mappings,
      })
    end,
  },
  {
    "johmsalas/text-case.nvim",
    config = function()
      local textcase = safe_import("textcase")
      textcase.setup({})
    end,
  },
  {
    "nvim-pack/nvim-spectre",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local spectre = safe_import("spectre")
      spectre.setup()
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
      local illuminate = safe_import("illuminate")

      illuminate.configure({
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
  {
    "echasnovski/mini.bufremove",
    keys = {
      {
        "xx",
        function()
          local mini_bufremove = safe_import("mini.bufremove")
          local buff_delete = mini_bufremove.delete

          if vim.bo.modified then
            local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
            if choice == 1 then -- Yes
              vim.cmd.write()
              buff_delete(0)
            elseif choice == 2 then -- No
              buff_delete(0, true)
            end
          else
            buff_delete(0)
          end
        end,
        desc = "Delete Buffer",
      },
    },
  },
  -- Open links without netrw
  -- https://github.com/chrishrb/gx.nvim
  {
    "chrishrb/gx.nvim",
    keys = {
      { "gx", "<cmd>Browse<cr>", mode = { "n", "x" } },
    },
    cmd = { "Browse" },
    init = function()
      vim.g.netrw_nogx = 1 -- disable netrw gx
    end,
    dependencies = { "nvim-lua/plenary.nvim" },
    config = true, -- default settings
    submodules = false, -- not needed, submodules are required only for tests
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
