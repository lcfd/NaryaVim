local M = {}

local default_picker_setting = {
  theme = "dropdown",
  initial_mode = "normal",
}

local dropdown_no_preview_options = {
  theme = "dropdown",
  previewer = false,
}

local grep_options = {
  theme = "dropdown",
  only_sort_text = true,
}

local function get_pickers(actions)
  return {
    find_files = {
      theme = "dropdown",
      previewer = false,
      -- hidden = true,
    },
    live_grep = grep_options,
    grep_string = grep_options,
    buffers = {
      table.unpack(dropdown_no_preview_options),
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
      table.unpack(dropdown_no_preview_options),
      hidden = true,
      show_untracked = true,
    },
    lsp_references = default_picker_setting,
    lsp_definitions = default_picker_setting,
    lsp_declarations = default_picker_setting,
    lsp_implementations = default_picker_setting,
  }
end

function M.setup()
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
      ["ui-select"] = {
        require("telescope.themes").get_dropdown(),
      },
    },
  })

  telescope.load_extension("fzf")
  telescope.load_extension("project")
  telescope.load_extension("dap")
  telescope.load_extension("textcase")
  telescope.load_extension("zk")
  -- It sets vim.ui.select to telescope.
  telescope.load_extension("ui-select")
end

return M
