local safe_import = require("utils.safe_import")
local by_filetype = require("plugins.formatter.config_by_filetype")

return {
  {
    "stevearc/conform.nvim",
    lazy = true,
    -- To disable, comment next line
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = safe_import("conform")

      conform.setup({
        -- Apply formatters based on file types
        formatters_by_ft = by_filetype(conform),
      })
    end,
  },
}