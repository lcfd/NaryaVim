-- Indent guides for Neovim

return {
  "lukas-reineke/indent-blankline.nvim",
  main = "ibl",
  config = function(_)
    local highlight = {
      "RainbowRed",
      "RainbowYellow",
      "RainbowBlue",
      "RainbowOrange",
      "RainbowGreen",
      "RainbowViolet",
      "RainbowCyan",
    }

    local hooks = require("ibl.hooks")
    hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
      vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#bb9af7" })
      vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#7aa2f7" })
      vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#2ac3de" })
      vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#7dcfff" })
      vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#e0af68" })
      vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#e0af68" })
      vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#f7768e" })
    end)

    require("ibl").setup({
      indent = { highlight = highlight },
      scope = { enabled = false },
      space_char_blankline = " ",
    })
  end,
}
