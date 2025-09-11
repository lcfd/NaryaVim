return {
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {},
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        automatic_enable = false,
      })

      vim.lsp.enable({
        "ruff",
        "pylsp",
        "eslint",
        "astro",
        "jsonls",
        "sqlls",
        "taplo",
        "tailwindcss",
        "yamlls",
        "html",
        "dockerls",
        "docker_compose_language_service",
        "marksman",
        "vtsls",
        "lua_ls",
      })
    end,
  },
}
