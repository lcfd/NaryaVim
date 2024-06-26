-- A completion plugin for neovim coded in Lua.
-- https://github.com/hrsh7th/nvim-cmp

local safe_import = require("utils.safe_import")
local icons = require("config").icons.kinds
local border = require("plugins.cmp.config_border")
local sources = require("plugins.cmp.config_sources")
local mappings = require("plugins.cmp.config_mappings")
local autocomplete = false

return {
  "hrsh7th/nvim-cmp",
  version = false,
  -- Load cmp on InsertEnter
  event = "InsertEnter",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "saadparwaiz1/cmp_luasnip",
    "rafamadriz/friendly-snippets",
    -- "hrsh7th/cmp-cmdline",
  },
  config = function(_, opts)
    local cmp = safe_import("cmp")
    local luasnip = safe_import("luasnip")

    cmp.setup({
      completion = {
        autocomplete = autocomplete,
      },
      -- Snippets control
      snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
          if not luasnip then
            vim.notify("Snippet: No luasnip", "error")
            return
          end
          luasnip.lsp_expand(args.body) -- For `luasnip` users.
        end,
      },
      -- UI
      window = {
        completion = {
          border = border,
        },
        documentation = {
          border = border,
        },
      },
      -- Map keybindings
      mapping = cmp.mapping.preset.insert(mappings(cmp)),
      -- Format what the user sees in the menu
      formatting = {
        fields = {
          "kind",
          "abbr",
          "menu",
        },
        format = function(entry, vim_item)
          vim_item.kind = string.format("%s", icons[vim_item.kind])
          vim_item.menu = ({
            nvim_lsp = "[LSP]",
            luasnip = "[SN]",
            nvim_lsp_signature_help = "[LSPH]",
            treesitter = "[TST]",
            buffer = "[BU]",
            path = "[PA]",
          })[entry.source.name]
          return vim_item
        end,
      },
      -- Sources to load in suggestions
      sources = cmp.config.sources(sources),
      -- Experimental features
      experimental = {
        ghost_text = true,
      },
    })

    -- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline({
      "/",
      "?",
    }, {
      mapping = cmp.mapping.preset.cmdline(),
      sources = {
        {
          name = "buffer",
        },
      },
    })
  end,
}