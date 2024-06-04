local default_picker_setting = {
  theme = "dropdown",
  initial_mode = "normal",
}

local grep_options = {
  theme = "dropdown",
  only_sort_text = true,
}

local function get_pickers(actions)
  return {
    find_files = {
      theme = "dropdown",
      previewer = true,
      wrap_results = true,
      path_display = { "absolute" },
    },
    commands = {
      theme = "dropdown",
    },
    live_grep = grep_options,
    grep_string = grep_options,
    buffers = {
      theme = "dropdown",
      previewer = false,
      initial_mode = "normal",
      mappings = {
        i = {
          ["<C-d>"] = actions.delete_buffer,
        },
        n = {
          ["dd"] = actions.delete_buffer,
        },
      },
    },
    git_files = {
      theme = "dropdown",
      previewer = false,
      hidden = true,
      show_untracked = true,
    },
    lsp_references = default_picker_setting,
    lsp_definitions = default_picker_setting,
    lsp_declarations = default_picker_setting,
    lsp_implementations = default_picker_setting,
  }
end

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
      -- "nvim-telescope/telescope-dap.nvim"
    },
    config = function()
      local telescope_status_ok, telescope = pcall(require, "telescope")
      if not telescope_status_ok then
        vim.notify("Require Telescope.", "error")
        return
      end

      local status_tsa_ok, actions = pcall(require, "telescope.actions")
      if not status_tsa_ok then
        vim.notify("Require Telescope actions.", "error")
        return
      end

      local themes = require("telescope.themes")

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
          vimgrep_arguments = {
            "rg",
            "--color=never",
            "--no-heading",
            "--with-filename",
            "--line-number",
            "--column",
            "--smart-case",
            "--hidden",
            "--glob=!.git/",
          },
          winblend = 0,
          color_devicons = true,
          set_env = {
            ["COLORTERM"] = "truecolor",
          },
        },
        pickers = get_pickers(actions),
        extensions = {
          -- fzf = {
          --   fuzzy = true,
          --   override_generic_sorter = true,
          --   override_file_sorter = true,
          --   case_mode = "smart_case",
          -- },
          ["ui-select"] = {
            themes.get_dropdown(),
          },
        },
      })
      -- From stimpack https://github.com/johmsalas/text-case.nvim
      telescope.load_extension("textcase")
      -- Notify
      telescope.load_extension("notify")
      -- fzf
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")

      -- Using obsidian.nvim now
      -- telescope.load_extension("zk")

      -- It's here for future dap usage
      -- telescope.load_extension("dap")
    end,
  },
}
