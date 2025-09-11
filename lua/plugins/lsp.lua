return {
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {},
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
    config = function()
      require("mason-lspconfig").setup({
        automatic_enable = false,
      })

      vim.lsp.enable({
        "ruff",
        "pylsp",
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

-- return {
--   {
--     "saghen/blink.cmp",
--     dependencies = { "rafamadriz/friendly-snippets" },

--     config = function()
--       vim.lsp.enable({
--         "ruff",
--         "pylsp",
--         "eslint",
--         "astro",
--         "jsonls",
--         "sqlls",
--         "taplo",
--         "tailwindcss",
--         "yamlls",
--         "html",
--         "dockerls",
--         "docker_compose_language_service",
--         "marksman",
--         "vtsls",
--         "lua_ls",
--       })

--       vim.lsp.config("vtsls", {
--         capabilities = require("blink.cmp").get_lsp_capabilities(),
--       })

--       vim.api.nvim_create_autocmd("LspAttach", {
--         callback = function(event)
--           local map = function(keys, func, desc, mode)
--             mode = mode or "n"
--             vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
--           end

--           map("gr", require("telescope.builtin").lsp_references, "[Telescope] [G]oto [R]eferences")
--         end,
--       })
--     end,
--   },
-- }
