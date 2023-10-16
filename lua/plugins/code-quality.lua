return {
  {
    "mfussenegger/nvim-lint",
    config = function()
      require("lint").linters_by_ft = {
        markdown = {
          -- "vale",
          "markdownlint",
          "proselint",
        },
        python = {
          "mypy",
          "ruff",
        },
        yaml = {
          "yamllint",
        },
        javascript = {
          "eslint_d",
        },
        typescript = {
          "eslint_d",
        },
        javascriptreact = {
          "eslint_d",
        },
        typescriptreact = {
          "eslint_d",
        },
        json = {
          "jsonlint",
        },
        html = {
          "djlint",
        },
        css = {
          "stylelint",
        },
        sh = {
          "shellcheck",
        },
      }

      vim.api.nvim_create_autocmd({
        "InsertLeave",
        "BufWritePost",
      }, {
        callback = function()
          local lint_status, lint = pcall(require, "lint")
          if lint_status then
            lint.try_lint()
          end
        end,
      })
    end,
  },
  {
    "stevearc/conform.nvim",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          htmldjango = { "djlint" },
          lua = { "stylua" },
          python = { "black" },
          json = { "prettier" },
          javascript = { "prettier" },
          html = { "prettier", "djlint" },
          typescript = { "prettier" },
          javascriptreact = { "prettier" },
          typescriptreact = { "prettier" },
          css = { "prettier" },
          markdown = {
            "prettier",
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
