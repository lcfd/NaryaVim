-- A completion plugin for neovim coded in Lua.
-- https://github.com/hrsh7th/nvim-cmp

return {
  "hrsh7th/nvim-cmp",
  version = false,
  -- Load cmp on InsertEnter
  event = "InsertEnter",
  -- These dependencies will only be loaded when cmp loads.
  -- Dependencies are always lazy-loaded unless specified otherwise.
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function(_, opts)
    local icons = require("config").icons.kinds
    local status_ok, cmp = pcall(require, "cmp")
    if not status_ok then
      vim.notify("No cmp", "error")
      return
    end
    local lua_snip_status_ok, luasnip = pcall(require, "luasnip")
    if not lua_snip_status_ok then
      vim.notify("Setup: No luasnip", "error")
      return
    end

    cmp.setup({
      completion = {
        autocomplete = false,
      },
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
      window = {
        completion = {
          border = {
            "╭",
            "─",
            "╮",
            "│",
            "╯",
            "─",
            "╰",
            "│",
          },
        },
        documentation = {
          border = {
            "╭",
            "─",
            "╮",
            "│",
            "╯",
            "─",
            "╰",
            "│",
          },
        },
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-d>"] = cmp.mapping.complete(),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        ["<CR>"] = cmp.mapping.confirm({
          select = true,
        }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-j>"] = cmp.mapping(function(_)
          luasnip.jump(1)
        end, {
          "i",
          "s",
        }),
        ["<C-k>"] = cmp.mapping(function(_)
          luasnip.jump(-1)
        end, {
          "i",
          "s",
        }),
      }),
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
            nvim_lsp_signature_help = "[LSPH]",
            luasnip = "[SN]",
            buffer = "[BU]",
            treesitter = "[TST]",
            path = "[PA]",
          })[entry.source.name]
          return vim_item
        end,
      },
      sources = cmp.config.sources({
        {
          name = "nvim_lsp_signature_help",
        },
        {
          name = "nvim_lsp",
        },
        { name = "path" },
        {
          name = "luasnip",
        },
        {
          name = "buffer",
        },
        {
          name = "treesitter",
        },
      }),

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

    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline(),
      sources = cmp.config.sources({
        {
          name = "path",
        },
      }, {
        {
          name = "cmdline",
        },
      }),
    })
  end,
}
