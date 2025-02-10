-- ### LSP

local servers = {
  ruff = {},      -- Python
  pyright = {},   -- Python
  eslint = {},    -- JS
  astro = {},     -- Astro
  jsonls = {},    -- JSON
  sqlls = {},     -- SQL
  taplo = {},     -- TOML
  tailwindcss = { -- TailwindCSS
    tailwindCSS = {
      experimental = {
        classRegex = {
          { "cva\\(([^)]*)\\)",          "[\"'`]([^\"'`]*).*?[\"'`]" },
          { "cx\\(([^)]*)\\)",           "(?:'|\"|`)([^']*)(?:'|\"|`)" },
          { "([\"'`][^\"'`]*.*?[\"'`])", "[\"'`]([^\"'`]*).*?[\"'`]" },
        },
      },
    },
  },
  yamlls = {},                          -- YAML
  html = {},                            -- HTML
  dockerls = {},                        -- Docker
  docker_compose_language_service = {}, -- Docker
  lua_ls = {                            -- Lua
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
      diagnostics = { disable = { "missing-fields" } },
    },
  },
  marksman = {}, -- Markdown
  vtsls = {},    -- TypeScript

  -- ###############
  -- Other servers
  -- ###############

  -- htmx = {},     -- HTMX
  -- gopls = {}, -- Go
  -- tsserver = {}, -- TypeScript Alternavie
  -- mdx_analyzer = {}, - MDX
  -- zk = {}, -- Zettelkasten
  -- graphql = {}, -- QraphQL
}

return {
  -- {
  --   'jmbuhr/otter.nvim',
  --   dependencies = {
  --     'nvim-treesitter/nvim-treesitter',
  --   },
  --   opts = {},
  --   config = function()
  --   end
  -- },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      'saghen/blink.cmp'
    },

    opts = {
      -- Options for vim.diagnostic.config()
      diagnostics = {
        virtual_text = false,
      },
    },

    config = function(_, opts)
      vim.diagnostic.config(vim.deepcopy(opts.diagnostics))
    end,
  },
  -- Mason
  {
    "williamboman/mason.nvim",
    dependencies = {
      { "williamboman/mason-lspconfig.nvim" },
    },
    cmd = "Mason",
    opts = {},
    config = function()
      local mason = require("mason")
      local mason_lspconfig = require("mason-lspconfig")
      local lspconfig = require("lspconfig")
      local blink = require('blink.cmp')

      -- Mason
      mason.setup()
      mason_lspconfig.setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
      })

      -- Capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = blink.get_lsp_capabilities(capabilities)

      mason_lspconfig.setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({
            capabilities = capabilities,
            settings = servers[server_name],
          })
        end,
      })
    end,
  },
}
