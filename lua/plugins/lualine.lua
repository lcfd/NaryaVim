local safe_import = require("utils.safe_import")
local icons = require("config").icons

local maxSizeFile = 5

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  dependencies = { "abeldekat/harpoonline", version = "*" },
  config = function()
    local Harpoonline = safe_import("harpoonline")
    local lualine = safe_import("lualine")

    Harpoonline.setup({
      on_update = function()
        lualine.refresh()
      end,
    })

    lualine.setup({
      extensions = { "nvim-tree", "lazy", "mason", "toggleterm" },
      options = {
        icons_enabled = true,
        theme = "tokyonight",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        component_separators = {
          left = "•",
          right = "•",
        },
        section_separators = {
          left = "",
          right = "",
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
        },
        lualine_x = {
          { "filetype", separator = "•", padding = { left = 1, right = 1 } },
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
          },
        },
        lualine_y = { Harpoonline.format },
        lualine_z = {
          { "location", padding = { left = 0, right = 1 } },
        },
      },
    })
  end,
}
