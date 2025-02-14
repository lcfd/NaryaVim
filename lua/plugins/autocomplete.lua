return {
  {
    "saghen/blink.cmp",
    enabled = true,
    dependencies = {
      { "L3MON4D3/LuaSnip", version = "v2.*" },
      "moyiz/blink-emoji.nvim",
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
        if filetype == "TelescopePrompt" or filetype == "minifiles" or filetype == "snacks_picker_input" then
          return false
        end
        return true
      end

      -- NOTE: The new way to enable LuaSnip
      -- Merge custom sources with the existing ones from lazyvim
      opts.sources = vim.tbl_deep_extend("force", opts.sources or {}, {
        default = { "lsp", "path", "snippets", "buffer", "emoji" },
        providers = {
          lsp = {
            name = "LSP",
            enabled = true,
            module = "blink.cmp.sources.lsp",
            min_keyword_length = 2,
            score_offset = 86,
          },
          path = {
            name = "Path",
            module = "blink.cmp.sources.path",
            score_offset = 25,
            -- When typing a path, I would get snippets and text in the
            -- suggestions, I want those to show only if there are no path
            -- suggestions
            fallbacks = { "snippets", "buffer" },
            min_keyword_length = 2,
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
            max_items = 15,
            min_keyword_length = 1,
            module = "blink.cmp.sources.snippets",
            score_offset = 85,
          },
          -- https://github.com/moyiz/blink-emoji.nvim
          emoji = {
            module = "blink-emoji",
            name = "Emoji",
            score_offset = 93, -- the higher the number, the higher the priority
            min_keyword_length = 3,
            opts = { insert = true }, -- Insert emoji (default) or complete its name
          },
        },
        -- command line completion, thanks to dpetka2001 in reddit
        -- https://www.reddit.com/r/neovim/comments/1hjjf21/comment/m37fe4d/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
        cmdline = function()
          local type = vim.fn.getcmdtype()
          if type == "/" or type == "?" then
            return { "buffer" }
          end
          if type == ":" then
            return { "cmdline" }
          end
          return {}
        end,
      })

      opts.completion = {
        keyword = {
          -- 'prefix' will fuzzy match on the text before the cursor
          -- 'full' will fuzzy match on the text before *and* after the cursor
          range = "full",
        },
        menu = {
          border = "single",
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 1500,
          window = {
            border = "single",
          },
        },
        -- Displays a preview of the selected item on the current line
        ghost_text = {
          enabled = true,
        },
      }

      opts.fuzzy = {
        -- Frecency tracks the most recently/frequently used items and boosts the score of the item
        use_frecency = true,
        -- Proximity bonus boosts the score of items matching nearby words
        use_proximity = false,
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
      }

      opts.signature = { enabled = true }

      return opts
    end,
    opts_extend = { "sources.default" },
  },
}
