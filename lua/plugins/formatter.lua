local prettier = { "prettier", "prettierd", stop_after_first = true }

return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>ff",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = "",
        desc = "[F]ormat buffer",
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style.
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = "fallback",
          }
        end
      end,
      formatters_by_ft = {
        lua = { "stylua" },
        htmldjango = prettier,
        html = prettier,

        python = { "ruff_format" },

        astro = prettier,

        javascript = prettier,
        typescript = prettier,
        javascriptreact = prettier,
        typescriptreact = prettier,

        vue = prettier,

        css = prettier,

        markdown = {
          "prettier",
          "markdown-toc",
          "markdownlint",
        },
        json = prettier,
        go = {
          "gofmt",
          "gofumpt",
          "goimports",
          "golines",
        },
      },
    },
  },
}
