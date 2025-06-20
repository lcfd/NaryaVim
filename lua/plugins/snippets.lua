return {
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    dependencies = { "rafamadriz/friendly-snippets", "saghen/blink.cmp" },
    build = (function()
      if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
        return
      end
      return "make install_jsregexp"
    end)(),
    lazy = true,
    config = function()
      local luasnip = require("luasnip")

      luasnip.filetype_extend("python", {
        "django",
      })

      luasnip.filetype_extend("html", {
        "htmldjango",
        "javascript",
      })

      luasnip.filetype_extend("htmldjango", {
        "html",
        "javascript",
      })

      luasnip.filetype_extend("typescriptreact", {
        "html",
      })

      luasnip.filetype_extend("javascriptreact", {
        "html",
      })

      luasnip.filetype_extend("typescript", {
        "javascript",
      })

      luasnip.filetype_extend("astro", {
        "html",
      })

      luasnip.filetype_extend("vue", {
        "html",
        "javascript",
      })

      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
}
