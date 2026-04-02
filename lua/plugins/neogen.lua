local opts = { noremap = true, silent = true }

return {
  "danymat/neogen",
  dependencies = { "rafamadriz/friendly-snippets", "saghen/blink.cmp" },
  config = true,
  -- Follow only stable versions
  version = "*",
  keys = {
    {
      "<leader>nf",
      ":lua require('neogen').generate({ type = 'func' })<CR>",
      opts,
    },
     {
      "<leader>nc",
      ":lua require('neogen').generate({ type = 'class' })<CR>",
      opts,
    },
  },
  opts = {
    snippet_engine = "luasnip",
    languages = {
      javascript = {
        template = {
          annotation_convention = "jsdoc",
        },
      },
      {
        typescript = {
          template = {
            annotation_convention = "tsdoc",
          },
        },
      },
      {
        typescriptreact = {
          template = {
            annotation_convention = "tsdoc",
          },
        },
      },
    },
  },
}
