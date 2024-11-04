local safe_import = require("utils.safe_import")

return {
  "stevearc/oil.nvim",
  opts = {},
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local oil = safe_import("oil")

    if oil then
      local setup = {
        default_file_explorer = false,
        columns = {
          "icon",
        },
        keymaps = {
          ["<C-h>"] = false,
        },
        view_options = {
          show_idden = true,
        },
      }

      oil.setup(setup)
    end

    vim.keymap.set("n", "<leader>p", "<CMD>Oil<CR>", {
      desc = "[Oil] Open parent directory.",
    })
  end,
}
