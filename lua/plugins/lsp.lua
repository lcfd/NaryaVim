return {
  "mason-org/mason.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  config = function()
    require("mason").setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    vim.lsp.config["lua_ls"] = {}
    vim.lsp.config["vtsls"] = {
      settings = {
        -- typescript = {
        --   preferences = { includePackageJsonAutoImports = "off" },
        -- },
        vtsls = {
          experimental = {
            completion = {
              enableServerSideFuzzyMatch = true,
              entriesLimit = 50,
            },
          },
        },
      },
      filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
    }
    vim.lsp.config["ruff"] = {}
    vim.lsp.config["ty"] = {}
    vim.lsp.config["pyright"] = {}
    vim.lsp.config["eslint"] = {}
    vim.lsp.config["astro"] = {}
    vim.lsp.config["jsonls"] = {}
    vim.lsp.config["sqlls"] = {}
    vim.lsp.config["taplo"] = {}
    vim.lsp.config["tailwindcss"] = {}
    vim.lsp.config["yamlls"] = {}
    vim.lsp.config["html"] = {}
    vim.lsp.config["dockerls"] = {}
    vim.lsp.config["docker_compose_language_service"] = {}
    vim.lsp.config["marksman"] = {}

    vim.lsp.enable({
      "ruff",
      "ty",
      "pyright",
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
  -- keys = {
    -- {
    --   "gr",
    --   vim.lsp.buf.references,
    --   desc = "References",
    -- },
  -- },
}
