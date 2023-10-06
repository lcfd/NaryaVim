return {
  "RRethy/vim-illuminate",
  event = {
    "BufReadPost",
    "BufNewFile",
  },
  opts = {
    delay = 200,
    large_file_cutoff = 2000,
    large_file_overrides = {
      providers = {
        "lsp",
      },
    },
  },
  config = function(_)
    require("illuminate").configure({
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = {
          "lsp",
        },
      },
    })
  end,
}
