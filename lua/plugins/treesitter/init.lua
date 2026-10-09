local ensure_installed = require("plugins.treesitter.config_ensure_installed")

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    branch = "main",
    lazy = false,
    -- mason puts the tree-sitter CLI on $PATH (see plugins/lsp.lua)
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      local function install_parsers()
        require("nvim-treesitter").install(ensure_installed)
      end

      if vim.fn.executable("tree-sitter") == 1 then
        install_parsers()
      else
        -- first start: wait for mason to install the CLI
        require("mason-registry"):on(
          "package:install:success",
          vim.schedule_wrap(function(pkg)
            if pkg.name == "tree-sitter-cli" then
              install_parsers()
            end
          end)
        )
      end

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start)
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
}
