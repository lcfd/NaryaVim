local safe_import = require("utils.safe_import")

return {
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      local gitsigns = safe_import("gitsigns")
      if gitsigns then
        gitsigns.setup()
      end
    end,
  },
}
