local M = {}

function M.setup()
  -- ########################
  -- ####### Luasnip ########
  -- ########################

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

  require("luasnip.loaders.from_vscode").lazy_load()

  -- #########################
  -- ########## CMP ##########
  -- #########################

  local status_ok, cmp = pcall(require, "cmp")
  if not status_ok then
    vim.notify("No cmp", "error")
    return
  end

  --   פּ ﯟ   some other good icons
  local kind_icons = {
    Text = "",
    Method = "m",
    Function = "",
    Constructor = "",
    Field = "",
    Variable = "",
    Class = "",
    Interface = "",
    Module = "",
    Property = "",
    Unit = "",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "",
    Event = "",
    Operator = "",
    TypeParameter = "",
  }

  cmp.setup({
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
      -- completion = cmp.config.window.bordered(),
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
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({
        select = true,
      }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
      ["<C-p>"] = cmp.mapping.select_prev_item(),
      ["<C-n>"] = cmp.mapping.select_next_item(),
      ["<C-j>"] = cmp.mapping(function(fallback)
        luasnip.jump(1)
      end, {
        "i",
        "s",
      }),
      ["<C-k>"] = cmp.mapping(function(fallback)
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
        vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
        vim_item.menu = ({
          nvim_lsp = "[LSP]",
          luasnip = "[SN]",
          buffer = "[BU]",
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
      {
        name = "luasnip",
      },
      {
        name = "buffer",
        keyword_length = 4,
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
end

return M
