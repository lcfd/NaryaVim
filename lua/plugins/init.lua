return {
  {
    "mickael-menu/zk-nvim",
    config = function()
      require("zk").setup({
        picker = "telescope",
      })
    end,
  },
  -- { "folke/neoconf.nvim", cmd = "Neoconf", config = true },
  -- { "folke/neodev.nvim", opts = {} },
}
