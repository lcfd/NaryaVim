-- by_filetype
local prettier = { "prettierd", "prettier" }

return function(conform)
  local config = {
    htmldjango = { "djhtml" },
    html = { "djhtml" },
    lua = { "stylua" },
    python = function(bufnr)
      if conform.get_formatter_info("ruff_format", bufnr).available then
        return { "ruff_format" }
      else
        return { "isort", "black" }
      end
    end,
    json = { prettier },
    javascript = { prettier },
    typescript = { prettier },
    javascriptreact = { prettier },
    typescriptreact = { prettier },
    css = { prettier },
    markdown = {
      prettier,
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
