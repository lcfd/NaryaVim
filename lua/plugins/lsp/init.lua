-- ### LSP

local servers = {
  ruff = {}, -- Python
  pyright = {}, -- Python
  eslint = {}, -- JS
  astro = {}, -- Astro
  jsonls = {}, -- JSON
  sqlls = {}, -- SQL
  taplo = {}, -- TOML
  tailwindcss = { -- TailwindCSS
    settings = {
      tailwindCSS = {
        experimental = {
          classRegex = {
            { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
            { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
            { "([\"'`][^\"'`]*.*?[\"'`])", "[\"'`]([^\"'`]*).*?[\"'`]" },
          },
        },
      },
    },
  },
  yamlls = {}, -- YAML
  html = {}, -- HTML
  dockerls = {}, -- Docker
  docker_compose_language_service = {}, -- Docker
  lua_ls = { -- Lua
    settings = {
      Lua = {
        workspace = { checkThirdParty = false },
        telemetry = { enable = false },
        diagnostics = { disable = { "missing-fields" } },
      },
    },
  },
  marksman = {}, -- Markdown
  vtsls = {}, -- TypeScript
  -- Vue 3
  volar = {},
  ts_ls = {}, -- TypeScript ts_ls is just for Vue

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
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "williamboman/mason.nvim" },
      { "williamboman/mason-lspconfig.nvim" },
      { "saghen/blink.cmp" },
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
      local blink = require("blink.cmp")

      -- Mason
      mason.setup()

      mason_lspconfig.setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
      })

      -- Capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      local mason_registry = require("mason-registry")
      local vue_language_server = mason_registry.get_package("vue-language-server"):get_install_path()
        .. "/node_modules/@vue/language-server"

      capabilities = blink.get_lsp_capabilities(capabilities)

      -- ts_ls is just for Vue
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        init_options = {
          plugins = {
            {
              name = "@vue/typescript-plugin",
              location = vue_language_server,
              languages = { "vue" },
            },
          },
        },
        filetypes = { "vue" },
      })

      mason_lspconfig.setup_handlers({
        function(server_name)
          if server_name ~= "volar" and server_name ~= "ts_ls" then
            local options = { capabilities = capabilities }

            if servers[server_name] then
              for k, v in pairs(servers[server_name]) do
                table.insert(options, { [k] = v })
              end
            end

            lspconfig[server_name].setup(options)
          end
        end,
      })
    end,
  },
}
