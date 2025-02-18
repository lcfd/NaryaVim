local prettier = { "prettierd", "prettier", stop_after_first = true }

-- Map formatters to filetypes
return function(conform)
  local config = {
    -- Django formatter works thanks to https://github.com/davidodenwald/prettier-plugin-jinja-template
    htmldjango = prettier,
    html = prettier,

    lua = { "stylua" },

    python = { "ruff_format" },

    astro = prettier,

    javascript = prettier,
    typescript = prettier,
    javascriptreact = prettier,
    typescriptreact = prettier,

    css = prettier,

    markdown = {
      "prettierd",
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
  }

  return config
end
