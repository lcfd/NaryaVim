return {
  {
    "mfussenegger/nvim-lint",
    config = function()
      require("lint").linters_by_ft = {
        markdown = { "vale", "markdownlint", "proselint" },
        python = { "mypy", "ruff" },
        yaml = { "yamllint" },
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
        html = { "djlint" },
        css = { "stylelint" },
        sh = { "shellcheck" },
      }

      vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost" }, {
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
    "mhartington/formatter.nvim",
    config = function()
      local util = require("formatter.util")

      require("formatter").setup({
        log_level = vim.log.levels.WARN,
        filetype = {
          htmldjango = {
            function()
              return {
                exe = "djlint",
                args = {
                  util.escape_path(util.get_current_buffer_file_path()),
                  "--reformat",
                  "--format-css",
                  "--format-js",
                  "-",
                },
                stdin = true,
                no_append = true,
              }
            end,
          },
          html = {
            require("formatter.filetypes.html").prettier,
          },
          lua = {
            require("formatter.filetypes.lua").stylua,
          },
          python = {
            require("formatter.filetypes.python").black,
          },
          javascript = {
            require("formatter.filetypes.javascript").prettier,
          },
          typescript = {
            require("formatter.filetypes.typescript").prettier,
          },
          javascriptreact = {
            require("formatter.filetypes.javascriptreact").prettier,
          },
          typescriptreact = {
            require("formatter.filetypes.typescriptreact").prettier,
          },
          css = {
            require("formatter.filetypes.css").prettier,
          },
          markdown = {
            require("formatter.filetypes.markdown").prettier,
          },
        },
      })
    end,
  },
}
