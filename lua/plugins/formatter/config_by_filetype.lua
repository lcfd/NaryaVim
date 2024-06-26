-- by_filetype
local prettier = { "prettierd", "prettier" }

return function(conform)
  local config = {
    htmldjango = { "djlint" },
    -- htmldjango = { { "prettierd", "prettier" }, "djlint" },
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
    html = { prettier, "djlint" },
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
