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
        function()
          local api = require("nvim-tree.api")
          api.tree.toggle()
        end,
        desc = "[NvimTree] Toggle (cwd)",
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
  -- {
  --   "nvim-neo-tree/neo-tree.nvim",
  --   cmd = "Neotree",
  --   dependencies = {
  --     "nvim-lua/plenary.nvim",
  --     "MunifTanjim/nui.nvim",
  --   },
  --   keys = {
  --     {
  --       "\\",
  --       function()
  --         require("neo-tree.command").execute({
  --           toggle = true,
  --           dir = vim.loop.cwd(),
  --         })
  --       end,
  --       desc = "[NeoTree] Toggle (cwd)",
  --     },
  --   },
  --   config = function()
  --     require("neo-tree").setup({
  --
  --       close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
  --       popup_border_style = "rounded",
  --       enable_git_status = true,
  --       enable_diagnostics = true,
  --       sort_case_insensitive = true, -- used when sorting files and directories in the tree
  --       sort_function = nil,
  --
  --       -- group_empty_dirs = false,
  --       -- hijack_netrw_behavior = "disabled",
  --       -- use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
  --       -- bind_to_cwd = true,
  --
  --       default_component_configs = {
  --         container = {
  --           enable_character_fade = true,
  --         },
  --         indent = {
  --           indent_size = 2,
  --           padding = 1, -- extra padding on left hand side
  --           -- indent guides
  --           with_markers = true,
  --           indent_marker = "│",
  --           last_indent_marker = "└",
  --           highlight = "NeoTreeIndentMarker",
  --           -- expander config, needed for nesting files
  --           with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
  --           expander_collapsed = "",
  --           expander_expanded = "",
  --           expander_highlight = "NeoTreeExpander",
  --         },
  --         icon = {
  --           folder_closed = "",
  --           folder_open = "",
  --           folder_empty = "∅",
  --           -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
  --           -- then these will never be used.
  --           default = "*",
  --           highlight = "NeoTreeFileIcon",
  --         },
  --         modified = {
  --           symbol = "[+]",
  --           highlight = "NeoTreeModified",
  --         },
  --         name = {
  --           trailing_slash = false,
  --           use_git_status_colors = true,
  --           highlight = "NeoTreeFileName",
  --         },
  --         git_status = {
  --           symbols = {
  --             -- Change type
  --             added = "✚", -- or "✚", but this is redundant info if you use git_status_colors on the name
  --             modified = "󰏪", -- or "", but this is redundant info if you use git_status_colors on the name
  --             deleted = "✖", -- this can only be used in the git_status source
  --             renamed = "", -- this can only be used in the git_status source
  --
  --             -- Status type
  --             untracked = "Untracked",
  --             ignored = "",
  --             unstaged = "",
  --
  --             staged = "",
  --             conflict = "Conflict",
  --           },
  --         },
  --         type = {
  --           enabled = true,
  --           required_width = 122, -- min width of window required to show this column
  --         },
  --         last_modified = {
  --           enabled = true,
  --           required_width = 88, -- min width of window required to show this column
  --         },
  --         created = {
  --           enabled = true,
  --           required_width = 110, -- min width of window required to show this column
  --         },
  --         symlink_target = {
  --           enabled = false,
  --         },
  --       },
  --
  --       window = {
  --         position = "float",
  --         mapping_options = {
  --           noremap = true,
  --           nowait = true,
  --         },
  --         mappings = {
  --           ["<space>"] = {
  --             "toggle_node",
  --             nowait = false, -- disable `nowait` if you have existing combos starting with this char that you want to use
  --           },
  --           ["<2-LeftMouse>"] = "open",
  --           ["<cr>"] = "open",
  --           ["<esc>"] = "revert_preview",
  --           ["P"] = {
  --             "toggle_preview",
  --             config = {
  --               use_float = true,
  --             },
  --           },
  --           ["S"] = "open_split",
  --           ["s"] = "open_vsplit",
  --           -- ["S"] = "split_with_window_picker",
  --           ["t"] = "open_tabnew",
  --           -- ["<cr>"] = "open_drop",
  --           ["w"] = "open_with_window_picker",
  --           -- ["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
  --           ["C"] = "close_node",
  --           ["z"] = "close_all_nodes",
  --           -- ["Z"] = "expand_all_nodes",
  --           ["a"] = {
  --             "add",
  --             config = {
  --               show_path = "none", -- "none", "relative", "absolute"
  --             },
  --           },
  --           ["A"] = "add_directory", -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
  --           ["d"] = "delete",
  --           ["r"] = "rename",
  --           ["y"] = "copy_to_clipboard",
  --           ["x"] = "cut_to_clipboard",
  --           ["p"] = "paste_from_clipboard",
  --           ["c"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
  --           ["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
  --           ["q"] = "close_window",
  --           ["R"] = "refresh",
  --           ["?"] = "show_help",
  --           ["<"] = "prev_source",
  --           [">"] = "next_source",
  --         },
  --       },
  --       nesting_rules = {},
  --       filesystem = {
  --         follow_current_file = {
  --           enabled = true,
  --           leave_dirs_open = false,
  --         },
  --         group_empty_dirs = false,
  --         hijack_netrw_behavior = "open_default",
  --         use_libuv_file_watcher = true, -- This will use the OS level file watchers to detect changes
  --         bind_to_cwd = true,
  --
  --         filtered_items = {
  --           visible = false, -- when true, they will just be displayed differently than normal items
  --           hide_dotfiles = false,
  --           hide_gitignored = false,
  --           hide_hidden = true, -- only works on Windows for hidden files/directories
  --           hide_by_name = {
  --             -- "node_modules"
  --           },
  --           hide_by_pattern = { -- uses glob style patterns
  --             -- "*.meta",
  --             -- "*/src/*/tsconfig.json",
  --           },
  --           always_show = { -- remains visible even if other settings would normally hide it
  --             ".gitignore",
  --             ".git",
  --           },
  --           never_show = {},
  --           never_show_by_pattern = {
  --             -- ".null-ls_*",
  --           },
  --         },
  --         -- instead of relying on nvim autocmd events.
  --         window = {
  --           mappings = {
  --             ["<esc>"] = "close_window",
  --             ["<bs>"] = "",
  --             ["."] = "",
  --             -- ["<bs>"] = "navigate_up",
  --             -- ["."] = "set_root",
  --             ["H"] = "toggle_hidden",
  --             ["/"] = "fuzzy_finder",
  --             ["D"] = "fuzzy_finder_directory",
  --             ["f"] = "filter_on_submit",
  --             ["<c-x>"] = "clear_filter",
  --             ["[g"] = "prev_git_modified",
  --             ["]g"] = "next_git_modified",
  --             -- ["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
  --             -- ["oc"] = { "order_by_created", nowait = false },
  --             -- ["od"] = { "order_by_diagnostics", nowait = false },
  --             -- ["og"] = { "order_by_git_status", nowait = false },
  --             -- ["om"] = { "order_by_modified", nowait = false },
  --             -- ["on"] = { "order_by_name", nowait = false },
  --             -- ["os"] = { "order_by_size", nowait = false },
  --             -- ["ot"] = { "order_by_type", nowait = false },
  --           },
  --           fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
  --             ["<down>"] = "move_cursor_down",
  --             ["<C-n>"] = "move_cursor_down",
  --             ["<up>"] = "move_cursor_up",
  --             ["<C-p>"] = "move_cursor_up",
  --           },
  --         },
  --       },
  --       buffers = {
  --         follow_current_file = {
  --           enabled = true,
  --           leave_dirs_open = false,
  --         },
  --         group_empty_dirs = false,
  --         show_unloaded = true,
  --         window = {
  --           mappings = {
  --             ["bd"] = "buffer_delete",
  --             ["<bs>"] = "",
  --             -- ["<bs>"] = "navigate_up",
  --             ["."] = "set_root",
  --             -- ["o"] = { "show_help", nowait = false, config = { title = "Order by", prefix_key = "o" } },
  --             -- ["oc"] = { "order_by_created", nowait = false },
  --             -- ["od"] = { "order_by_diagnostics", nowait = false },
  --             -- ["om"] = { "order_by_modified", nowait = false },
  --             -- ["on"] = { "order_by_name", nowait = false },
  --             -- ["os"] = { "order_by_size", nowait = false },
  --             -- ["ot"] = { "order_by_type", nowait = false },
  --           },
  --         },
  --       },
  --       git_status = {
  --         window = {
  --           position = "float",
  --           mappings = {
  --             ["A"] = "git_add_all",
  --             ["gu"] = "git_unstage_file",
  --             ["ga"] = "git_add_file",
  --             ["gr"] = "git_revert_file",
  --             ["gc"] = "git_commit",
  --             ["gp"] = "git_push",
  --             ["gg"] = "git_commit_and_push",
  --           },
  --         },
  --       },
  --     })
  --   end,
  -- },
}
