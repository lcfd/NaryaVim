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
  {
    "lukas-reineke/headlines.nvim",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true, -- or `opts = {}`
  },
  {
    "iamcco/markdown-preview.nvim",
    lazy = true,
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
    -- config = function()
    -- vim.g.mkdp_open_ip = "127.0.0.1"
    -- vim.g.mkdp_port = "8888"
    -- vim.g.mkdp_open_to_the_world = 0
    -- end,
  }
}
