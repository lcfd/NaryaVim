local M = {}

local function get_pickers(actions)
  local default_picker_setting = {
    theme = "dropdown",
    initial_mode = "normal",
  }

  local grep = {
    only_sort_text = true,
    theme = "dropdown",
  }

  return {
    find_files = {
      theme = "dropdown",
      hidden = true,
      previewer = false,
    },
    live_grep = grep,
    grep_string = grep,
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
      hidden = true,
      previewer = false,
      show_untracked = true,
    },
    lsp_references = default_picker_setting,
    lsp_definitions = default_picker_setting,
    lsp_declarations = default_picker_setting,
    lsp_implementations = default_picker_setting,
  }
end

function M.setup()
  local status_ok, telescope = pcall(require, "telescope")
  if not status_ok then
    return
  end

  local status_tsa_ok, actions = pcall(require, "telescope.actions")
  if not status_tsa_ok then
    return
  end

  telescope.setup({
    defaults = {
      selection_strategy = "reset",
      sorting_strategy = "descending",
      layout_strategy = "horizontal",
      entry_prefix = "  ",
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
      path_display = {
        "absolute",
      },
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
    },
  })

  telescope.load_extension("fzf")
  telescope.load_extension("project")
  telescope.load_extension("dap")
end

return M
