local safe_import = require("utils.safe_import")
local by_filetype = require("plugins.formatter.config_by_filetype")

return {
  {
    "stevearc/conform.nvim",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local conform = safe_import("conform")
      if conform then
        conform.setup({
          formatters = {
            djhtml = {
              inherit = false,
              command = "djhtml",
              args = "cat $FILENAME | djhtml",
              stdin = false,
            },
          },
          -- Apply formatters based on file types
          formatters_by_ft = by_filetype(conform),
        })
      end
    end,
  },
}
