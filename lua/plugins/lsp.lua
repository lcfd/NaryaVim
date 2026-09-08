return {
  "mason-org/mason.nvim",
  dependencies = {
    -- provides default lsp/*.lua configs (cmd, filetypes, root_markers) that
    -- vim.lsp.config merges with; must be loaded before vim.lsp.enable() below
    "neovim/nvim-lspconfig",
  },
  config = function()
    require("mason").setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    vim.lsp.config["lua_ls"] = {}
    vim.lsp.config["vtsls"] = {
      cmd = { "vtsls", "--stdio" },
      root_markers = { "tsconfig.json", "jsconfig.json", "package.json", ".git" },
      settings = {
        -- typescript = {
        --   preferences = { includePackageJsonAutoImports = "off" },
        -- },
        vtsls = {
          experimental = {
            completion = {
              enableServerSideFuzzyMatch = true,
              entriesLimit = 50,
            },
          },
        },
      },
      filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
    }
    vim.lsp.config["ruff"] = {}
    vim.lsp.config["ty"] = {}
    vim.lsp.config["pyright"] = {}
    vim.lsp.config["eslint"] = {}
    vim.lsp.config["astro"] = {}
    vim.lsp.config["jsonls"] = {}
    vim.lsp.config["sqlls"] = {}
    vim.lsp.config["taplo"] = {}
    vim.lsp.config["tailwindcss"] = {}
    vim.lsp.config["yamlls"] = {}
    vim.lsp.config["html"] = {}
    vim.lsp.config["dockerls"] = {}
    vim.lsp.config["docker_compose_language_service"] = {}
    vim.lsp.config["marksman"] = {
      -- Fall back to the file's own directory when no project root
      -- (.marksman.toml/.git) is found, so standalone .md files outside
      -- any repo still get a working LSP session. Also ignore a `.git`
      -- found at $HOME (e.g. a dotfiles repo tracking the home dir) —
      -- otherwise marksman treats the whole home directory as its
      -- workspace and never finishes indexing it.
      root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local root = vim.fs.root(fname, { ".marksman.toml", ".git" })
        if root == vim.uv.os_homedir() then
          root = nil
        end
        on_dir(root or vim.fs.dirname(fname))
      end,
    }
    vim.lsp.config["bashls"] = {}

    vim.lsp.enable({
      "ruff",
      "ty",
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
      "bashls",
      "vtsls",
      "lua_ls",
    })
  end,
}
