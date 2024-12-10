-- by_filetype
local prettier = { "prettierd", "prettier", stop_after_first = true }

return function(conform)
  local config = {
    htmldjango = { "djhtml" },
    html = { "djhtml" },
    lua = { "stylua" },
    python = { "ruff_format" },
    json = prettier,
    javascript = prettier,
    typescript = prettier,
    javascriptreact = prettier,
    typescriptreact = prettier,
    css = { prettier },
    markdown = {
      "prettierd",
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
  }

  return config
end
