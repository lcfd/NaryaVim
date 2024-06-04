return {
  {
    "stevearc/conform.nvim",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          htmldjango = { "djlint" },
          -- htmldjango = { { "prettierd", "prettier" }, "djlint" },
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
