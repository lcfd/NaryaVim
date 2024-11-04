-- ### LSP

-- Keybindings and other configurations
local on_attach = require("plugins.lsp.on_attach")

local servers = {
  ruff_lsp = {},  -- Python
  pyright = {},   -- Python
  -- basedpyright = {}, -- Python
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
  ltex = {                              -- Spellcheck
    ltex = {
      languageToolHttpServerUri = "http://localhost:8010/",
      checkFrequency = "save",
      completionEnabled = false,
    },
  },
  lua_ls = { -- Lua
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

  -- gopls = {}, -- Go
  -- tsserver = {}, -- TypeScript Alternavie
  -- mdx_analyzer = {}, - MDX
  -- zk = {}, -- Zettelkasten
  -- graphql = {}, -- QraphQL
}

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
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
      { "hrsh7th/cmp-nvim-lsp" },
    },
    cmd = "Mason",
    opts = {},
    config = function()
      local mason = require("mason")
      local mason_lspconfig = require("mason-lspconfig")

      mason.setup()

      mason_lspconfig.setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
      })

      local lspconfig = require("lspconfig")

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      mason_lspconfig.setup_handlers({
        function(server_name)
          lspconfig[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = servers[server_name],
          })
        end,
      })
    end,
  },
}
