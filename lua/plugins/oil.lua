local safe_import = require("utils.safe_import")

return {
  "stevearc/oil.nvim",
  opts = {},
  -- Optional dependencies
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local oil = safe_import("oil")

    if oil then
      oil.setup({
        default_file_explorer = false,
        columns = {
          "icon",
          -- "permissions"
        },
        keymaps = {
          ["<C-h>"] = false,
        },
        view_options = {
          show_idden = true,
        },
      })
    end

    -- vim.keymap.set("n", "<leader>p", oil.toggle_float, {
    vim.keymap.set("n", "<leader>p", "<CMD>Oil<CR>", {
      desc = "[Oil] Open parent directory.",
    })
  end,
}
