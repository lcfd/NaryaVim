return {
  -- UI
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
  {
    "MunifTanjim/nui.nvim",
    lazy = true,
  },
  {
    "johmsalas/text-case.nvim",
  },
  {
    "rcarriga/nvim-notify",
  },
  {
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
    },
    opts = {
      theme = "catppuccin",
    },
  },

  -- LSP
  -- {
  --   "neovim/nvim-lspconfig",
  -- },
  -- {
  --   "williamboman/mason.nvim",
  --   build = ":MasonUpdate",
  -- },
  -- {
  --   "williamboman/mason-lspconfig.nvim",
  -- },


  -- CMP
  -- {
  --   "hrsh7th/nvim-cmp",
  --   -- load cmp on InsertEnter
  --   event = "InsertEnter",
  --   -- these dependencies will only be loaded when cmp loads
  --   -- dependencies are always lazy-loaded unless specified otherwise
  --   dependencies = {
  --     "hrsh7th/cmp-nvim-lsp",
  --     "hrsh7th/cmp-buffer",
  --     "hrsh7th/cmp-path",
  --     "hrsh7th/cmp-cmdline",
  --     "hrsh7th/cmp-nvim-lsp-signature-help",
  --     "saadparwaiz1/cmp_luasnip",
  --   },
  -- },

  -- Git
  {
    "TimUntersberger/neogit",
    dependencies = "nvim-lua/plenary.nvim",
  },
  -- Tests
  {
    "nvim-neotest/neotest",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
    },
  },
  {
    "nvim-neotest/neotest-python",
  },
  -- Misc
  
  {
    "numToStr/Comment.nvim",
  },
  {
    "kylechui/nvim-surround",
  },

  -- Markdown
  {
    "mickael-menu/zk-nvim",
    config = function()
      require("zk").setup({
        picker = "telescope",
        -- See Setup section below
      })
    end,
  },

  -- Utils
  {
    "nanotee/zoxide.vim",
  },
}
