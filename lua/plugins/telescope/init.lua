local safe_import = require("utils.safe_import")
local get_pickers = require("plugins.telescope.get_pickers")

local vimgrep_arguments = {
  "rg",
  "--color=never",
  "--no-heading",
  "--with-filename",
  "--line-number",
  "--column",
  "--smart-case",
  "--hidden",
  "--glob=!.git/",
  "--glob=!.yarn/",
  "--glob=!*.min.{js,css}"
}

return {
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = "make",

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      "nvim-telescope/telescope-symbols.nvim",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-live-grep-args.nvim",
      -- "nvim-telescope/telescope-dap.nvim"
    },
    config = function()
      local telescope = safe_import("telescope")
      local actions = safe_import("telescope.actions")
      local themes = safe_import("telescope.themes")

      if telescope and themes then
        telescope.setup({
          defaults = {
            selection_strategy = "reset",
            sorting_strategy = "descending",
            layout_strategy = "horizontal",
            entry_prefix = "  ",
            path_display = {
              "smart",
              -- "absolute",
            },
            vimgrep_arguments = vimgrep_arguments,
            winblend = 0,
            color_devicons = true,
            set_env = {
              ["COLORTERM"] = "truecolor",
            },
          },
          pickers = get_pickers(actions),
          extensions = {
            fzf = {
              fuzzy = true,
              override_generic_sorter = true,
              override_file_sorter = true,
              case_mode = "smart_case",
            },
            ["ui-select"] = {
              themes.get_dropdown(),
            },
            live_grep_args = {
              auto_quoting = true, -- enable/disable auto-quoting
            },
          },
        })
        -- From stimpack https://github.com/johmsalas/text-case.nvim
        telescope.load_extension("textcase")

        -- Notify
        -- telescope.load_extension("notify")

        -- fzf
        telescope.load_extension("fzf")
        telescope.load_extension("ui-select")

        -- Live grep
        telescope.load_extension("live_grep_args")
      end


      -- It's here for future dap usage
      -- telescope.load_extension("dap")

      -- Using obsidian.nvim now
      -- telescope.load_extension("zk")
    end,
  },
}
