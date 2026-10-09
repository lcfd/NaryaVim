-- LSP server name -> mason package that provides it
local servers = {
  ruff = "ruff",
  ty = "ty",
  pyright = "pyright",
  eslint = "eslint-lsp",
  astro = "astro-language-server",
  jsonls = "json-lsp",
  sqlls = "sqlls",
  taplo = "taplo",
  tailwindcss = "tailwindcss-language-server",
  yamlls = "yaml-language-server",
  html = "html-lsp",
  dockerls = "dockerfile-language-server",
  docker_compose_language_service = "docker-compose-language-service",
  marksman = "marksman",
  bashls = "bash-language-server",
  clangd = "clangd",
  vtsls = "vtsls",
  lua_ls = "lua-language-server",
}

-- Non-LSP mason packages: formatters used by conform (see formatter.lua) and
-- the tree-sitter CLI needed to build parsers (see treesitter/init.lua).
-- gofmt is not here: it ships with the Go toolchain.
local tools = { "stylua", "prettier", "tree-sitter-cli" }

-- Install every missing package so a fresh setup works on first start.
-- Servers whose package finishes installing are re-enabled, which attaches
-- them to buffers that were opened while the install was running.
local function ensure_installed()
  local registry = require("mason-registry")

  local server_of = {}
  for server, pkg in pairs(servers) do
    server_of[pkg] = server
  end
  registry:on(
    "package:install:success",
    vim.schedule_wrap(function(pkg)
      if server_of[pkg.name] then
        vim.lsp.enable(server_of[pkg.name])
      end
    end)
  )

  registry.refresh(vim.schedule_wrap(function()
    for _, name in ipairs(vim.list_extend(vim.tbl_values(servers), tools)) do
      local ok, pkg = pcall(registry.get_package, name)
      if not ok then
        vim.notify("mason: unknown package " .. name, vim.log.levels.WARN)
      elseif not pkg:is_installed() and not pkg:is_installing() then
        -- e.g. clangd has no linux arm64 build: install it with the system
        -- package manager instead, it is picked up from $PATH
        if pkg:is_installable() then
          pkg:install()
        else
          vim.notify("mason: " .. name .. " is not available on this platform", vim.log.levels.WARN)
        end
      end
    end
  end))
end

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

    vim.lsp.enable(vim.tbl_keys(servers))
    ensure_installed()
  end,
}
