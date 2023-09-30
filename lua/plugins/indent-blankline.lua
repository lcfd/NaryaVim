-- Indent guides for Neovim

return {
  "lukas-reineke/indent-blankline.nvim",
  opts = {
    show_end_of_line = true,
    space_char_blankline = " ",
    show_current_context_start = true,
    char_highlight_list = {
      "IndentBlanklineIndent1",
      "IndentBlanklineIndent2",
      "IndentBlanklineIndent3",
      "IndentBlanklineIndent4",
      "IndentBlanklineIndent5",
      "IndentBlanklineIndent6",
    },
  },
  config = function(_, opts)
    vim.cmd([[highlight IndentBlanklineIndent1 guifg=#bb9af7 gui=nocombine]])
    vim.cmd([[highlight IndentBlanklineIndent2 guifg=#7aa2f7 gui=nocombine]])
    vim.cmd([[highlight IndentBlanklineIndent3 guifg=#2ac3de gui=nocombine]])
    vim.cmd([[highlight IndentBlanklineIndent4 guifg=#7dcfff gui=nocombine]])
    vim.cmd([[highlight IndentBlanklineIndent5 guifg=#e0af68 gui=nocombine]])
    vim.cmd([[highlight IndentBlanklineIndent6 guifg=#f7768e gui=nocombine]])

    require("ibl").setup(opts)
  end,
}
