return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
  {
    "MunifTanjim/nui.nvim",
    lazy = true,
  },
  {
    "rcarriga/nvim-notify",
  },
  {
    "utilyre/barbecue.nvim", -- Top bar code path
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
    },
    opts = {
      theme = "catppuccin",
    },
  },
}
