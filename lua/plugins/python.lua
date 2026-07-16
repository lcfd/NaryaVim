return {
  "linux-cultist/venv-selector.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
  },
  opts = {},
  keys = {
    { "<leader>vs", "<cmd>VenvSelect<cr>", { desc = "[VenvSelector] Select." } },
    { "<leader>vc", "<cmd>VenvSelectCached<cr>", { desc = "[VenvSelector] Select cached." } },
  },
}
