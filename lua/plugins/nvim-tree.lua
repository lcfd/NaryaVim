return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    keys = {
      {
        "\\",
        "<CMD>NvimTreeToggle<CR>",
        desc = "[NvimTree] Toggle (cwd)",
        mode = "n",
      },
    },
    config = function()
      local gwidth = vim.api.nvim_list_uis()[1].width
      local gheight = vim.api.nvim_list_uis()[1].height
      local width = 60
      local height = 30

      require("nvim-tree").setup({
        hijack_netrw = false,
        reload_on_bufenter = true,
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
        view = {
          centralize_selection = true,
          relativenumber = true,
          float = {
            enable = true,
            open_win_config = {
              relative = "editor",
              border = "rounded",
              width = width,
              height = height,
              row = (gheight - height) * 0.4,
              col = (gwidth - width) * 0.4,
            },
          },
        },
        diagnostics = {
          enable = false,
        },
        modified = {
          enable = false,
        },
        renderer = {
          highlight_git = true,
        },
      })
    end,
  },
}
