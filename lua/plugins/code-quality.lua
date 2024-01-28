return {
  -- {
  --   "mfussenegger/nvim-lint",
  --   config = function()
  --     -- local lint = require('lint')
  --     local lint_status, lint = pcall(require, "lint")
  --
  --     -- local mypy = lint.linters.mypy
  --     -- mypy.args = {
  --     --   "."
  --     -- '--show-column-numbers',
  --     -- '--hide-error-codes',
  --     -- '--hide-error-context',
  --     -- '--no-color-output',
  --     -- '--no-error-summary',
  --     -- '--no-pretty',
  --     --   -- '--disallow-untyped-defs'
  --     -- }
  --
  --     lint.linters_by_ft = {
  --       markdown = {
  --         "vale",
  --       },
  --       python = {
  --         -- "mypy",
  --         -- "ruff",
  --       },
  --       yaml = {
  --         "yamllint",
  --       },
  --       javascript = {
  --         "eslint",
  --       },
  --       typescript = {
  --         "eslint",
  --       },
  --       javascriptreact = {
  --         "eslint",
  --       },
  --       typescriptreact = {
  --         "eslint",
  --       },
  --       json = {
  --         "jsonlint",
  --       },
  --       html = {
  --         "djlint",
  --       },
  --       css = {
  --         "stylelint",
  --       },
  --       sh = {
  --         "shellcheck",
  --       },
  --     }
  --
  --     vim.api.nvim_create_autocmd({
  --       "InsertLeave",
  --       "BufWritePost",
  --     }, {
  --       callback = function()
  --         if lint_status then
  --           lint.try_lint()
  --         end
  --       end,
  --     })
  --   end,
  -- },
  {
    "stevearc/conform.nvim",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          htmldjango = { { "prettierd", "prettier" }, "djlint" },
          lua = { "stylua" },
          python = function(bufnr)
            if require("conform").get_formatter_info("ruff_format", bufnr).available then
              return { "ruff_format" }
            else
              return { "isort", "black" }
            end
          end,
          json = { { "prettierd", "prettier" } },
          javascript = { { "prettierd", "prettier" } },
          html = { { "prettierd", "prettier" }, "djlint" },
          typescript = { "prettier" },
          javascriptreact = { { "prettierd", "prettier" } },
          typescriptreact = { { "prettierd", "prettier" } },
          css = { { "prettierd", "prettier" } },
          markdown = {
            { "prettierd", "prettier" },
            "markdown-toc",
            "markdownlint",
          },
          go = {
            "gofmt",
            "gofumpt",
            "goimports",
            "golines",
          },
        },
      })
    end,
  },
}
