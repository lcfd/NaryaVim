return {
  {
    "saghen/blink.cmp",
    enabled = true,
    dependencies = {
      { "L3MON4D3/LuaSnip", version = "v2.*" },
      -- 'jmbuhr/otter.nvim', Maybe in the future
    },
    version = "*",
    opts = function(_, opts)
      -- Telescope was extremeley slow and taking too long to open, related to blink.
      -- Disabling blink.cmp for Telescope
      opts.enabled = function()
        -- Get the current buffer's filetype
        local filetype = vim.bo[0].filetype
        -- Disable for Telescope buffers
        if filetype == "TelescopePrompt" or filetype == "snacks_picker_input" then
          return false
        end
        return true
      end

      -- NOTE: The new way to enable LuaSnip
      -- Merge custom sources with the existing ones from lazyvim;qa
      opts.sources = vim.tbl_deep_extend("force", opts.sources or {}, {
        default = { "lsp", "snippets", "path", "buffer" },
        providers = {
          lsp = {
            name = "LSP",
            enabled = true,
            module = "blink.cmp.sources.lsp",
            min_keyword_length = 0,
            score_offset = 96,
          },
          path = {
            name = "Path",
            module = "blink.cmp.sources.path",
            score_offset = 25,
            max_items = 3,
            -- When typing a path, I would get snippets and text in the
            -- suggestions, I want those to show only if there are no path
            -- suggestions
            -- fallbacks = { "snippets", "buffer" },
            min_keyword_length = 4,
            opts = {
              trailing_slash = false,
              label_trailing_slash = true,
              get_cwd = function(context)
                return vim.fn.expand(("#%d:p:h"):format(context.bufnr))
              end,
              show_hidden_files_by_default = true,
            },
          },
          buffer = {
            name = "Buffer",
            enabled = true,
            max_items = 3,
            module = "blink.cmp.sources.buffer",
            min_keyword_length = 4,
            score_offset = 15, -- the higher the number, the higher the priority
          },
          snippets = {
            name = "snippets",
            enabled = true,
            max_items = 10,
            min_keyword_length = 1,
            module = "blink.cmp.sources.snippets",
            score_offset = 80,
          },
        },
        -- cmdline = function()
        --   local type = vim.fn.getcmdtype()
        --   if type == "/" or type == "?" then
        --     return { "buffer" }
        --   end
        --   if type == ":" then
        --     return { "cmdline" }
        --   end
        --   return {}
        -- end,
      })

      opts.completion = {
        keyword = {
          range = "prefix",
        },
        menu = {
          border = "single",
          auto_show = true,
          draw = {
            treesitter = { "lsp" },
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 }},
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 1000,
          window = {
            border = "single",
          },
        },
      }

      opts.snippets = {
        preset = "luasnip",
        -- This comes from the luasnip extra, if you don't add it, won't be able to
        -- jump forward or backward in luasnip snippets
        -- https://www.lazyvim.org/extras/coding/luasnip#blinkcmp-optional
        expand = function(snippet)
          require("luasnip").lsp_expand(snippet)
        end,
        active = function(filter)
          if filter and filter.direction then
            return require("luasnip").jumpable(filter.direction)
          end
          return require("luasnip").in_snippet()
        end,
        jump = function(direction)
          require("luasnip").jump(direction)
        end,
      }

      opts.keymap = {
        preset = "enter",
        ["<C-space>"] = {
          function(cmp)
            cmp.show({ providers = { "lsp" } })
          end,
        },
      }

      opts.signature = { enabled = true }

      opts.appearance = {
        kind_icons = require("config").icons.kinds,
      }

      return opts
    end,
    opts_extend = { "sources.default" },
  },
}
