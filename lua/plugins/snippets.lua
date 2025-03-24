return {
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    dependencies = { "rafamadriz/friendly-snippets" },
    build = "make install_jsregexp",
    lazy = true,
    config = function()
      local luasnip = require("luasnip")
      local loader_from_vscode = require("luasnip.loaders.from_vscode")

      -- luasnip.config.set_config(config)

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

      luasnip.filetype_extend("astro", {
        "html",
      })

      loader_from_vscode.lazy_load()
      -- Not necessary, imported by blink.cmp
      -- loader_from_vscode.lazy_load({ paths = "~/.config/nvim/snippets" })
    end,
  },
}
