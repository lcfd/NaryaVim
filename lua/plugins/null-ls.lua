return {
  "jose-elias-alvarez/null-ls.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "mason.nvim", { "jayp0521/mason-null-ls.nvim" } },
  opts = function()
    local null_ls = require("null-ls")
    return {
      root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),
      sources = {
        null_ls.builtins.formatting.shfmt,
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.black,
        null_ls.builtins.formatting.djlint,
        null_ls.builtins.formatting.prettier,
        null_ls.builtins.code_actions.eslint_d,
        null_ls.builtins.diagnostics.markdownlint,
        null_ls.builtins.diagnostics.proselint,
        null_ls.builtins.diagnostics.mypy,
      },
    }
  end,
}
