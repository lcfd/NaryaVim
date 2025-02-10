return {
  {
    "saghen/blink.cmp",
    dependencies = {
      { "L3MON4D3/LuaSnip", version = "v2.*" },
      -- 'jmbuhr/otter.nvim',
    },
    version = "*",
    opts = {
      keymap = { preset = "enter" },

      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      },

      sources = {
        -- https://cmp.saghen.dev/recipes.html#dynamically-picking-providers-by-treesitter-node-filetype
        default = function(ctx)
          local success, node = pcall(vim.treesitter.get_node)
          if vim.bo.filetype == 'lua' then
            return { 'lsp', 'path' }
          elseif success and node and vim.tbl_contains({ 'comment', 'line_comment', 'block_comment' }, node:type()) then
            return { 'buffer' }
          else
            return { 'lsp', 'snippets', 'path', 'buffer' }
          end
        end,
      },

      signature = { enabled = true },

      completion = {
        menu = { border = 'single' },
        list = {
          selection = {
            preselect = true,
            auto_insert = false,
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 1500,
          window = { border = 'single' }
        },
      },

      snippets = {
        preset = "luasnip",
      },
    },
    -- Required, sources are modified
    opts_extend = { "sources.default" },
  },
}
