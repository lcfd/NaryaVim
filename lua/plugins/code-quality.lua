return {
  {
    "mfussenegger/nvim-lint",
    config = function()
      require("lint").linters_by_ft = {
        markdown = {
          "vale",
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
    config = function()
      require("conform").setup({
        format_on_save = {
          timeout_ms = 500,
          lsp_fallback = true,
        },
        formatters_by_ft = {
          htmldjango = {
            "djlint",
          },
          lua = {
            "stylua",
          },
          python = {
            "ruff_fix",
            "ruff_format",
            "black",
          },
          json = {
            {
              "prettierd",
              "prettier",
            },
          },
          javascript = {
            {
              "prettierd",
              "prettier",
            },
          },
          html = {
            {
              "prettierd",
              "prettier",
            },
          },
          typescript = {
            {
              "prettierd",
              "prettier",
            },
          },
          javascriptreact = {
            {
              "prettierd",
              "prettier",
            },
          },
          typescriptreact = {
            {
              "prettierd",
              "prettier",
            },
          },
          css = {
            {
              "prettierd",
              "prettier",
            },
          },
          markdown = {
            "markdown-toc",
            "markdownlint",
          },
        },
      })
    end,
  },
}
