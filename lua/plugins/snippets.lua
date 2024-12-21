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

      if luasnip then
        local config = {
          history = true,
          ext_base_prio = 200,
          ext_prio_increase = 1,
          enable_autosnippets = false,
        }

        luasnip.config.set_config(config)

        luasnip.filetype_extend("python", {
          "django",
        })

        luasnip.filetype_extend("html", {
          "htmldjango",
        })

        luasnip.filetype_extend("htmldjango", {
          "html",
        })

        luasnip.filetype_extend("typescriptreact", {
          "html",
        })

        loader_from_vscode.lazy_load()
        loader_from_vscode.lazy_load({ paths = "~/.config/nvim/snippets" })
      end
    end,
  },
}
