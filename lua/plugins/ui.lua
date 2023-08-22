return {
  {
    "nvim-tree/nvim-web-devicons",
    lazy = true,
  },
  {
    "utilyre/barbecue.nvim", -- Top bar code path
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
    },
    opts = {
      theme = "tokyonight",
      show_dirname = false,
      show_modified = true,
    },
  },
}
