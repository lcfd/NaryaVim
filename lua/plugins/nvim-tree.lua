return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      { "nvim-tree/nvim-web-devicons", lazy = true },
    },
    config = function()
      local HEIGHT_RATIO = 0.8 -- You can change this
      local WIDTH_RATIO = 0.5 -- You can change this too

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
            open_win_config = function()
              local screen_w = vim.opt.columns:get()
              local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
              local window_w = screen_w * WIDTH_RATIO
              local window_h = screen_h * HEIGHT_RATIO
              local window_w_int = math.floor(window_w)
              local window_h_int = math.floor(window_h)
              local center_x = (screen_w - window_w) / 2
              local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()

              return {
                border = "rounded",
                relative = "editor",
                row = center_y,
                col = center_x,
                width = window_w_int,
                height = window_h_int,
              }
            end,
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
