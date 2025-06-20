-- ### LSP
return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      -- Mason must be loaded before its dependents so we need to set it up here.
      -- NOTE: `opts = {}` is the same as calling `require('mason').setup({})`
      { "mason-org/mason.nvim", opts = {} },
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",

      -- Useful status updates for LSP.
      { "j-hui/fidget.nvim", opts = {} },

      -- Allows extra capabilities provided by blink.cmp
      "saghen/blink.cmp",
    },
    config = function()
      --  This function gets run when an LSP attaches to a particular buffer.
      --    That is to say, every time a new file is opened that is associated with
      --    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
      --    function will be executed to configure the current buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          -- In this case, we create a function that lets us more easily define mappings specific
          -- for LSP related items. It sets the mode, buffer and description for us each time.
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map("<leader>ca", vim.lsp.buf.code_action, "[G]oto Code [A]ction", { "n", "x" })

          -- Find references for the word under your cursor.
          map("<leader>fr", require("telescope.builtin").lsp_references, "[Telescope] [G]oto [R]eferences")

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map("gri", require("telescope.builtin").lsp_implementations, "[Telescope] [G]oto [I]mplementation")

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map("<leader>fd", require("telescope.builtin").lsp_definitions, "[Telescope] [G]oto [D]efinition")

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map("<leader>fD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[Telescope] Open Document Symbols")

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map(
            "<leader>dS",
            require("telescope.builtin").lsp_dynamic_workspace_symbols,
            "[Telescope] Open Workspace Symbols"
          )

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          -- map("K", require("telescope.builtin").lsp_type_definitions, "[G]oto [T]ype Definition")

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            if vim.fn.has("nvim-0.11") == 1 then
              return client:supports_method(method, bufnr)
            else
              return client.supports_method(method, { bufnr = bufnr })
            end
          end
        end,
      })

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        } or {},
        virtual_text = false,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      -- Create new capabilities with blink.cmp, and then broadcast that to the servers.
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Enable the following language servers. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
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
        marksman = {}, -- Markdown
        vtsls = {}, -- TypeScript
        -- ts_ls = {}, -- TypeScript ts_ls is just for Vue

        lua_ls = {
          settings = {
            Lua = {
              completion = {
                callSnippet = "Replace",
              },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed

      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        "stylua", -- Used to format Lua code
      })
      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      require("mason-lspconfig").setup({
        ensure_installed = {}, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for ts_ls)
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })
    end,
  },
}

-- ####################################################
-- ####################################################
-- ####################################################
-- ####################################################
-- ####################################################

-- local servers = {
--   ruff = {}, -- Python
--   pyright = {}, -- Python
--   eslint = {}, -- JS
--   astro = {}, -- Astro
--   jsonls = {}, -- JSON
--   sqlls = {}, -- SQL
--   taplo = {}, -- TOML
--   tailwindcss = { -- TailwindCSS
--     settings = {
--       tailwindCSS = {
--         experimental = {
--           classRegex = {
--             { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
--             { "cx\\(([^)]*)\\)", "(?:'|\"|`)([^']*)(?:'|\"|`)" },
--             { "([\"'`][^\"'`]*.*?[\"'`])", "[\"'`]([^\"'`]*).*?[\"'`]" },
--           },
--         },
--       },
--     },
--   },
--   yamlls = {}, -- YAML
--   html = {}, -- HTML
--   dockerls = {}, -- Docker
--   docker_compose_language_service = {}, -- Docker
--   lua_ls = { -- Lua
--     settings = {
--       Lua = {
--         workspace = { checkThirdParty = false },
--         telemetry = { enable = false },
--         diagnostics = { disable = { "missing-fields" } },
--       },
--     },
--   },
--   marksman = {}, -- Markdown
--   vtsls = {}, -- TypeScript
--   -- Vue 3
--   volar = {},
--   ts_ls = {}, -- TypeScript ts_ls is just for Vue

--   -- ###############
--   -- Other servers
--   -- ###############

--   -- htmx = {},     -- HTMX
--   -- gopls = {}, -- Go
--   -- tsserver = {}, -- TypeScript Alternavie
--   -- mdx_analyzer = {}, - MDX
--   -- zk = {}, -- Zettelkasten
--   -- graphql = {}, -- QraphQL
-- }

-- return {
--   {
--     "neovim/nvim-lspconfig",
--     event = { "BufReadPre", "BufNewFile" },
--     dependencies = {
--       { "williamboman/mason.nvim" },
--       { "williamboman/mason-lspconfig.nvim" },
--       { "saghen/blink.cmp" },
--     },

--     opts = {
--       -- Options for vim.diagnostic.config()
--       diagnostics = {
--         virtual_text = false,
--       },
--     },

--     config = function(_, opts)
--       vim.diagnostic.config(vim.deepcopy(opts.diagnostics))
--     end,
--   },
--   -- Mason
--   {
--     "williamboman/mason.nvim",
--     dependencies = {
--       { "williamboman/mason-lspconfig.nvim" },
--     },
--     cmd = "Mason",
--     opts = {},
--     config = function()
--       local mason = require("mason")
--       local mason_lspconfig = require("mason-lspconfig")
--       local lspconfig = require("lspconfig")
--       local blink = require("blink.cmp")

--       -- Mason
--       mason.setup()

--       mason_lspconfig.setup({
--         ensure_installed = vim.tbl_keys(servers),
--         automatic_installation = true,
--       })

--       -- Capabilities
--       local capabilities = vim.lsp.protocol.make_client_capabilities()
--       capabilities.textDocument.foldingRange = {
--         dynamicRegistration = false,
--         lineFoldingOnly = true,
--       }

--       local mason_registry = require("mason-registry")
--       local vue_language_server = mason_registry.get_package("vue-language-server"):get_install_path()
--         .. "/node_modules/@vue/language-server"

--       capabilities = blink.get_lsp_capabilities(capabilities)

--       -- ts_ls is just for Vue
--       lspconfig.ts_ls.setup({
--         capabilities = capabilities,
--         init_options = {
--           plugins = {
--             {
--               name = "@vue/typescript-plugin",
--               location = vue_language_server,
--               languages = { "vue" },
--             },
--           },
--         },
--         filetypes = { "vue" },
--       })

--       mason_lspconfig.setup_handlers({
--         function(server_name)
--           if server_name ~= "volar" and server_name ~= "ts_ls" then
--             local options = { capabilities = capabilities }

--             if servers[server_name] then
--               for k, v in pairs(servers[server_name]) do
--                 table.insert(options, { [k] = v })
--               end
--             end

--             lspconfig[server_name].setup(options)
--           end
--         end,
--       })
--     end,
--   },
-- }
