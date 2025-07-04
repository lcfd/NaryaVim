local git_colors = {
  add = "#22c55e",
  change = "#ec4899",
  delete = "#f43f5e",
  ingore = "#545c7e",
}

return {
  {
    -- Theme
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        comments = { italic = true },
        on_colors = function(colors)
          colors.git = git_colors
        end,
      })
      vim.cmd([[colorscheme tokyonight]])
    end,
  },
  {
    -- Code path at the top
    "utilyre/barbecue.nvim",
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      theme = "tokyonight",
      show_dirname = true,
      -- show_basename = false,
      show_basename = true,
      show_modified = true,
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      notify = {
        enabled = false,
      },
      presets = {
        bottom_search = true,
        lsp_doc_border = true,
        command_palette = true,
      },
    },
  },
  {
    -- Floating statuslines for Neovim
    "b0o/incline.nvim",
    dependencies = {
      { "nvim-tree/nvim-web-devicons", lazy = true },
    },
    event = "BufReadPre",
    priority = 1200,
    config = function()
      local incline = require("incline")
      incline.setup({
        -- Force colors of the box
        -- highlight = {
        --   groups = {
        --     InclineNormal = { guibg = "#7752FE", guifg = "#F3F3F3" },
        --     InclineNormalNC = { guifg = "#F4F4F4", guibg = "#A9A9A9" },
        --   },
        -- },
        window = {
          margin = { vertical = 2, horizontal = 0 },
          placement = {
            horizontal = "right",
            vertical = "bottom",
          },
        },
        hide = {
          -- The file name must always be visible
          cursorline = false,
        },
        render = function(props)
          local devicons = require("nvim-web-devicons")
          local helpers = require("incline.helpers")

          -- https://neovim.io/doc/user/cmdline.html#filename-modifiers
          local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
          -- Relative path, it helps navigation
          local pathFilename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":.")
          if filename == "" then
            filename = "[No Name]"
          end
          local ft_icon, ft_color = devicons.get_icon_color(filename)
          if not ft_color then
            ft_color = "#401F71"
          end
          if not ft_icon then
            ft_icon = "󱥰"
          end
          local modified = vim.bo[props.buf].modified
          return {
            ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or "",
            "",
            { pathFilename, gui = modified and "bold,italic" or "" },
            " ",
            guibg = ft_color,
            guifg = helpers.contrast_color(ft_color),
          }
        end,
      })
    end,
  },
}
