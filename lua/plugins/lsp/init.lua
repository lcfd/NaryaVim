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
        -- group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
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
          -- map("<leader>gr", require("telescope.builtin").lsp_references, "[Telescope] [G]oto [R]eferences")
          map("gr", require("telescope.builtin").lsp_references, "[Telescope] [G]oto [R]eferences")

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map("gi", require("telescope.builtin").lsp_implementations, "[Telescope] [G]oto [I]mplementation")

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          -- map("<leader>gd", require("telescope.builtin").lsp_definitions, "[Telescope] [G]oto [D]efinition")
          map("gd", require("telescope.builtin").lsp_definitions, "[Telescope] [G]oto [D]efinition")

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
        eslint = { -- JS
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        },
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
        vtsls = {
          filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        },
        -- ts_ls = {},
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

      -- require("mason-lspconfig").setup({
      --   automatic_enable = vim.tbl_keys(servers or {}),
      -- })

      -- local ensure_installed = vim.tbl_keys(servers or {})
      -- vim.list_extend(ensure_installed, {
      --   "stylua", -- Used to format Lua code
      -- })
      -- require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      -- Ensure the servers and tools above are installed

      -- local ensure_installed = vim.tbl_keys(servers or {})
      -- vim.list_extend(ensure_installed, {
      --   "stylua", -- Used to format Lua code
      -- })
      -- local disabled_servers = {}

      -- require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      -- require("mason-lspconfig").setup({
      --   automatic_enable = ensure_installed,
      -- })

      -- for server_name, config in pairs(servers) do
      --   config.capabilities = vim.tbl_deep_extend("force", {}, capabilities, config.capabilities or {})
      --   vim.lsp.config(server_name, config)
      -- end
      for server_name, config in pairs(servers) do
        vim.lsp.config(server_name, config)
      end

      vim.lsp.enable({
        "ruff",
        "pyright",
        "eslint",
        "astro",
        "jsonls",
        "sqlls",
        "taplo",
        "tailwindcss",
        "yamlls",
        "html",
        "dockerls",
        "docker_compose_language_service",
        "marksman",
        "vtsls",
        "lua_ls",
      })
    end,
  },
}
