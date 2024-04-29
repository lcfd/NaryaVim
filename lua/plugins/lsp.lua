local on_attach = function(_, bufnr)
  local status_ok, tsbuiltin = pcall(require, "telescope.builtin")
  if not status_ok then
    return
  end

  -- A function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = "LSP: " .. desc
    end

    vim.keymap.set("n", keys, func, {
      buffer = bufnr,
      desc = desc,
    })
  end

  nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
  nmap("<leader>lr", vim.lsp.buf.rename, "Rename what's under the cursor.")
  nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

  nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
  nmap("gd", tsbuiltin.lsp_definitions, "[G]oto [D]efinition")
  nmap("gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
  nmap("gr", tsbuiltin.lsp_references, "[G]oto [R]eferences")
  nmap("gt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", "[G]oto [T]ype")
  nmap("<leader>ds", tsbuiltin.lsp_document_symbols, "[D]ocument [S]ymbols")
  nmap("<leader>ws", tsbuiltin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
  nmap(
    "<leader>li",
    tsbuiltin.lsp_implementations,
    "Goto the implementation of the word under the cursor if there's only one, otherwise show all options in Telescope."
  )
  nmap("K", vim.lsp.buf.hover, "Hover Documentation")
  nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

  -- Lesser used LSP functionality
  -- nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
  nmap("<leader>wl", function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, "[W]orkspace [L]ist Folders")
end

return {
  -- LSP
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },

    opts = {
      -- options for vim.diagnostic.config()
      diagnostics = {
        virtual_text = false,
      },
      -- diagnostics = {
      -- virtual_text = {
      --   prefix = "●",
      --   severity = {
      --     vim.diagnostic.severity.HINT,
      --   },
      -- },
      -- update_in_insert = true,
      -- underline = true,
      -- severity_sort = true,
      -- float = {
      --   focusable = false,
      --   style = "minimal",
      --   border = "rounded",
      --   source = "if_many",
      --   header = "",
      --   prefix = "",
      -- },
      -- virtual_text = {
      --   prefix = " "
      -- },
      -- },
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
      require("mason").setup()

      local servers = {
        ruff_lsp = {},
        pyright = {},
        eslint = {},
        -- tsserver = {},
        astro = {},
        jsonls = {},
        mdx_analyzer = {},
        sqlls = {},
        taplo = {},
        tailwindcss = {
          tailwindCSS = {
            experimental = {
              classRegex = {
                { "cva\\(([^)]*)\\)", "[\"'`]([^\"'`]*).*?[\"'`]" },
                { "cx\\(([^)]*)\\)",  "(?:'|\"|`)([^']*)(?:'|\"|`)" },
              },
            },
          },
        },
        yamlls = {},
        gopls = {},
        html = {},
        dockerls = {},
        docker_compose_language_service = {},
        ltex = {
          ltex = {
            languageToolHttpServerUri = "http://localhost:8010/",
            checkFrequency = "save",
            completionEnabled = true,
          },
        },
        lua_ls = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            diagnostics = { disable = { "missing-fields" } },
          },
        },
        marksman = {},
        -- A better lsp for TypeScript
        -- https://github.com/yioneko/vtsls
        vtsls = {}
        -- OLD
        -- zk = {},
        -- graphql = {},
        -- vale_ls = {},
      }

      require("mason-lspconfig").setup({
        ensure_installed = vim.tbl_keys(servers),
        automatic_installation = true,
      })

      local lspconfig = require("lspconfig")

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

      require("mason-lspconfig").setup_handlers({
        function(server_name) -- default handler (optional)
          lspconfig[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
            settings = servers[server_name],
          })
          -- end
        end,
        -- Next, you can provide a dedicated handler for specific servers.
        -- For example, a handler override for the `rust_analyzer`:
        -- ["rust_analyzer"] = function()
        --   require("rust-tools").setup({})
        -- end,
      })
    end,
  },
  -- {
  --   "pmizio/typescript-tools.nvim",
  --   dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  --   opts = {},
  -- },
}
