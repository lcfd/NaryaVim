return {
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    dependencies = { "rafamadriz/friendly-snippets" },
    build = "make install_jsregexp",
    lazy = true,
    config = function(_, opts)
      local status_ok, luasnip = pcall(require, "luasnip")
      if not status_ok then
        vim.notify("Setup: No luasnip", "error")
        return
      end

      luasnip.config.set_config({
        history = true,
        -- treesitter-hl has 100, use something higher (default is 200).
        ext_base_prio = 200,
        -- minimal increase in priority.
        ext_prio_increase = 1,
        enable_autosnippets = false,
        -- store_selection_keys = "<c-s>",
      })

      luasnip.filetype_extend("python", {
        "django",
      })

      luasnip.filetype_extend("html", {
        "htmldjango",
      })

      luasnip.filetype_extend("typescriptreact", {
        "html",
      })

      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_vscode").lazy_load({ paths = "~/.config/nvim/snippets" })
    end,
  },
}
