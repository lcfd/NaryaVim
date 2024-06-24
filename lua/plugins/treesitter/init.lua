local ensure_installed = require("plugins.treesitter.config_ensure_installed")
local movements = require("plugins.treesitter.config_movements")

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    version = false,
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
      "JoosepAlviste/nvim-ts-context-commentstring",
    },
    config = function()
      local treesitter = require("nvim-treesitter.configs")

      treesitter.setup({
        modules = {},

        highlight = {
          enable = true,
        },

        indent = {
          enable = true,
        },

        ensure_installed = ensure_installed,

        ignore_install = {},

        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = false,
            node_decremental = "<BS>",
          },
        },

        -- Install parsers synchronously (only applied to `ensure_installed`).
        sync_install = false,

        -- Automatically install missing parsers when entering buffer.
        auto_install = true,

        autopairs = {
          enable = true,
        },

        autotag = {
          enable = true,
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    lazy = true,
    config = function()
      local treesitter = require("nvim-treesitter.configs")
      treesitter.setup({
        textobjects = movements,
      })
    end,
  },
}
