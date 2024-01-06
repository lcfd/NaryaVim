return {
  "lukas-reineke/indent-blankline.nvim", -- Indent guides for Neovim
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
  main = "ibl",
  config = function()
    require("ibl").setup({
      scope = { enabled = false },
      exclude = {
        filetypes = {
          "help",
          "alpha",
          "dashboard",
          "lazy",
          "mason",
          "notify",
          "toggleterm",
          "lazyterm",
        },
      },
    })
  end,
}
