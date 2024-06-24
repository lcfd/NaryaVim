local default_picker_setting = {
  theme = "dropdown",
  initial_mode = "normal",
}

local grep_options = {
  theme = "dropdown",
  only_sort_text = true,
}

-- get_pickers
return function(actions)
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
