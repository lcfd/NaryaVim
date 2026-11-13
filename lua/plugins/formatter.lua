local prettier = { "prettier", "prettierd", stop_after_first = true }

return {
  {
    "stevearc/conform.nvim",
    cmd = { "ConformInfo" },
    -- <leader>ff lives in config/keymaps.lua (it would override a mapping here)
    opts = {
      notify_on_error = false,
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

        markdown = prettier,
        json = prettier,
        go = { "gofmt" },
      },
    },
  },
}
