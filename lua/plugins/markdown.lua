local safe_import = require("utils.safe_import")

return {
  {
    "bullets-vim/bullets.vim",
    ft = {
      "markdown",
      "text",
      "plaintex"
    },
  },
  {
    'arnamak/stay-centered.nvim',
    ft = {
      "markdown",
      "text",
      "plaintex"
    },
    config = function()
      local st_ce = safe_import("stay-centered")

      if st_ce then
        require('stay-centered').setup({
          -- :lua print(vim.bo.filetype)
          skip_filetypes = {},
          -- Set to false to disable by default
          enabled = true,
        })
      end
    end
  },
  -- {
  --   "lukas-reineke/headlines.nvim",
  --   dependencies = "nvim-treesitter/nvim-treesitter",
  --   config = true, -- or `opts = {}`
  -- },
}
