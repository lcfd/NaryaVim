local safe_import = require("utils.safe_import")

local file_types_to_exclude = {
  "help",
  "alpha",
  "dashboard",
  "lazy",
  "mason",
  "notify",
  "toggleterm",
  "lazyterm",
}

return {
  "lukas-reineke/indent-blankline.nvim", -- Indent guides for Neovim
  event = { "BufReadPost", "BufNewFile", "BufWritePre" },
  main = "ibl",
  config = function()
    local ibl = safe_import("ibl")

    if ibl then
      ibl.setup({
        scope = { enabled = true },
        exclude = {
          filetypes = file_types_to_exclude,
        },
      })
    end
  end,
}
