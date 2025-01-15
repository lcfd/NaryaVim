return {
  {
    "saghen/blink.cmp",
    dependencies = {
      { "L3MON4D3/LuaSnip", version = "v2.*" },
    },
    version = "*",
    opts = {
      -- keymap = { preset = 'default' },
      keymap = { preset = "enter" },

      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      },

      sources = {
        default = { "snippets", "lsp", "path", "buffer" },
      },

      signature = { enabled = true },

      completion = {
        list = {
          selection = {
            preselect = true,
            auto_insert = false,
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 1500,
        },
      },

      snippets = {
        preset = "luasnip",
        -- expand = function(snippet)
        --   local luasnip = require("luasnip")
        --   luasnip.lsp_expand(snippet)
        -- end,
        -- active = function(filter)
        --   local luasnip = require("luasnip")
        --   if filter and filter.direction then
        --     return luasnip.jumpable(filter.direction)
        --   end
        --   return luasnip.in_snippet()
        -- end,
        -- jump = function(direction)
        --   local luasnip = require("luasnip")
        --   luasnip.jump(direction)
        -- end,
      },
    },
    -- Required, sources are modified
    opts_extend = { "sources.default" },
  },
}
