local M = {}

function M.setup(config)

    -- #######################
    -- ######## Theme ########
    -- #######################

  require("tokyonight").setup({
    -- your configuration comes here
    -- or leave it empty to use the default settings
    style = "night",      -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
    light_style = "day",  -- The theme is used when the background is set to light
    -- transparent = true, -- Enable this to disable setting the background color
    transparent = false,  -- Enable this to disable setting the background color
    terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
    styles = {
      -- Style to be applied to different syntax groups
      -- Value is any valid attr-list value for `:help nvim_set_hl`
      comments = {
        italic = true,
      },
      keywords = {
        italic = true,
      },
      functions = {},
      variables = {},
      -- Background styles. Can be "dark", "transparent" or "normal"
      sidebars = "dark", -- style for sidebars, see below
      floats = "dark", -- style for floating windows
    },
    sidebars = {
      "qf",
      "help",
    },                              -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
    -- day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
    hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
    dim_inactive = false,           -- dims inactive windows
    lualine_bold = true,            -- When `true`, section headers in the lualine theme will be bold
    --- You can override specific color groups to use other groups or a hex color
    --- function will be called with a ColorScheme table
    ---@param colors ColorScheme
    on_colors = function(colors)
    end,
    --- You can override specific highlights to use other groups or a hex color
    --- function will be called with a Highlights and ColorScheme table
    ---@param highlights Highlights
    ---@param colors ColorScheme
    on_highlights = function(highlights, colors)
    end,
  })

  vim.cmd([[colorscheme tokyonight-night]])

  local status_ok, autopairs = pcall(require, "nvim-autopairs")
  if not status_ok then
    vim.notify("Require nvim-autopairs", "error")
    return
  end

  autopairs.setup()

  -- ##################################
  -- ######## indent_blankline ########
  -- ##################################

  local status_ok, indent_blankline = pcall(require, "indent_blankline")
  if not status_ok then
    vim.notify("Require indent_blankline", "error")
    return
  end

  vim.cmd([[highlight IndentBlanklineIndent1 guifg=#bb9af7 gui=nocombine]])
  vim.cmd([[highlight IndentBlanklineIndent2 guifg=#7aa2f7 gui=nocombine]])
  vim.cmd([[highlight IndentBlanklineIndent3 guifg=#2ac3de gui=nocombine]])
  vim.cmd([[highlight IndentBlanklineIndent4 guifg=#7dcfff gui=nocombine]])
  vim.cmd([[highlight IndentBlanklineIndent5 guifg=#e0af68 gui=nocombine]])
  vim.cmd([[highlight IndentBlanklineIndent6 guifg=#f7768e gui=nocombine]])

  indent_blankline.setup({
    show_end_of_line = true,
    space_char_blankline = " ",
    -- show_current_context = true,
    show_current_context_start = true,
    -- show_trailing_blankline_indent = false,
    char_highlight_list = {
      "IndentBlanklineIndent1",
      "IndentBlanklineIndent2",
      "IndentBlanklineIndent3",
      "IndentBlanklineIndent4",
      "IndentBlanklineIndent5",
      "IndentBlanklineIndent6",
    },
  })

  -- ############################
  -- ######## Bufferline ########
  -- ############################

    if config.bufferline_enabled then
        local status_ok, bufferline = pcall(require, "bufferline")
        if not status_ok then
            vim.notify("Require Bufferline", "error")
            return
        end

        bufferline.setup {
            options = {
                mode = "buffers"
            }
        }
    end

  -- #########################
  -- ######## Comment ########
  -- #########################

  local status_ok, comment = pcall(require, "Comment")
  if not status_ok then
    vim.notify("Require Comment", "error")
    return
  end

  comment.setup({
    toggler = {
      ---Line-comment toggle keymap
      line = "<leader>1",
      ---Block-comment toggle keymap
      block = "<leader>2",
    },
    opleader = {
      ---Line-comment keymap
      line = "<leader>1",
      ---Block-comment keymap
      block = "<leader>2",
    },
  })

  -- ########################
  -- ######## Neogit ########
  -- ########################

  local status_ok, neogit = pcall(require, "neogit")
  if not status_ok then
    vim.notify("Require Neogit", "error")
    return
  end

  neogit.setup({
    commit_popup = {
      kind = "split",
    },
  })

  -- ###################################
  -- ######## nvim-web-devicons ########
  -- ###################################

  local status_ok, webicons = pcall(require, "nvim-web-devicons")
  if not status_ok then
    vim.notify("Require nvim-web-devicons", "error")
    return
  end

  webicons.setup()

  -- ########################
  -- ######## Notify ########
  -- ########################

  local status_ok, notify = pcall(require, "notify")
  if not status_ok then
    vim.notify("Require notify", "error")
    return
  end

  notify.setup({
    stages = "static",
  })

  -- ######################
  -- ######## Leap ########
  -- ######################

  local status_ok, leap = pcall(require, "leap")
  if not status_ok then
    vim.notify("Require leap", "error")
    return
  end

  leap.add_default_mappings()

  -- ##########################
  -- ######## surround ########
  -- ##########################

  local status_ok, surround = pcall(require, "surround")
  if not status_ok then
    vim.notify("Require surround", "error")
    return
  end

  surround.setup({
    mappings_style = "sandwich",
    prefix = "<leader>h",
  })

  -- ##########################
  -- ######## zen mode ########
  -- ##########################
  require("zen-mode").setup({
    window = {
      width = 90,
      options = {
        number = true,
        relativenumber = true,
      },
    },
  })

    -- ##########################
    -- ######## neo-tree ########
    -- ##########################
    if config.neo_tree_enabled then
        require("neo-tree").setup({
            close_if_last_window = false, -- Close Neo-tree if it is the last window left in the tab
            popup_border_style = "rounded",
            enable_git_status = true,
            enable_diagnostics = true,
            sort_case_insensitive = true, -- used when sorting files and directories in the tree
            default_component_configs = {
                container = {
                    enable_character_fade = true
                },
                indent = {
                    indent_size = 2,
                    padding = 1, -- extra padding on left hand side
                    -- indent guides
                    with_markers = true,
                    indent_marker = "│",
                    last_indent_marker = "└",
                    highlight = "NeoTreeIndentMarker",
                    -- expander config, needed for nesting files
                    with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
                    expander_collapsed = "",
                    expander_expanded = "",
                    expander_highlight = "NeoTreeExpander"
                },
                icon = {
                    folder_closed = "",
                    folder_open = "",
                    folder_empty = "ﰊ",
                    -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
                    -- then these will never be used.
                    default = "*",
                    highlight = "NeoTreeFileIcon"
                },
                modified = {
                    symbol = "[+]",
                    highlight = "NeoTreeModified"
                },
                name = {
                    trailing_slash = false,
                    use_git_status_colors = true,
                    highlight = "NeoTreeFileName"
                },
                git_status = {
                    symbols = {
                        -- Change type
                        added = "✚", -- or "✚", but this is redundant info if you use git_status_colors on the name
                        modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
                        deleted = "✖", -- this can only be used in the git_status source
                        renamed = "", -- this can only be used in the git_status source
                        -- Status type
                        untracked = "",
                        ignored = "",
                        unstaged = "",
                        staged = "",
                        conflict = ""
                    }
                }
            },
            window = {
                position = "left",
                width = 40,
                mapping_options = {
                    noremap = true,
                    nowait = true
                },
                mappings = {
                    ["<space>"] = {
                        "toggle_node",
                        nowait = false -- disable `nowait` if you have existing combos starting with this char that you want to use 
                    },
                    ["<2-LeftMouse>"] = "open",
                    ["<cr>"] = "open",
                    ["<esc>"] = "revert_preview",
                    ["P"] = {
                        "toggle_preview",
                        config = {
                            use_float = true
                        }
                    },
                    ["S"] = "open_split",
                    ["s"] = "open_vsplit",
                    -- ["S"] = "split_with_window_picker",
                    -- ["s"] = "vsplit_with_window_picker",
                    ["t"] = "open_tabnew",
                    -- ["<cr>"] = "open_drop",
                    -- ["t"] = "open_tab_drop",
                    ["w"] = "open_with_window_picker",
                    -- ["P"] = "toggle_preview", -- enter preview mode, which shows the current node without focusing
                    ["C"] = "close_node",
                    ["z"] = "close_all_nodes",
                    -- ["Z"] = "expand_all_nodes",
                    ["a"] = {
                        "add",
                        -- this command supports BASH style brace expansion ("x{a,b,c}" -> xa,xb,xc). see `:h neo-tree-file-actions` for details
                        -- some commands may take optional config options, see `:h neo-tree-mappings` for details
                        config = {
                            show_path = "none" -- "none", "relative", "absolute"
                        }
                    },
                    ["A"] = "add_directory", -- also accepts the optional config.show_path option like "add". this also supports BASH style brace expansion.
                    ["d"] = "delete",
                    ["r"] = "rename",
                    ["y"] = "copy_to_clipboard",
                    ["x"] = "cut_to_clipboard",
                    ["p"] = "paste_from_clipboard",
                    ["c"] = "copy", -- takes text input for destination, also accepts the optional config.show_path option like "add":
                    -- ["c"] = {
                    --  "copy",
                    --  config = {
                    --    show_path = "none" -- "none", "relative", "absolute"
                    --  }
                    -- }
                    ["m"] = "move", -- takes text input for destination, also accepts the optional config.show_path option like "add".
                    ["q"] = "close_window",
                    ["R"] = "refresh",
                    ["?"] = "show_help",
                    ["<"] = "prev_source",
                    [">"] = "next_source"
                }
            },
            nesting_rules = {},
            filesystem = {
                filtered_items = {
                    visible = false, -- when true, they will just be displayed differently than normal items
                    hide_dotfiles = false,
                    hide_gitignored = false,
                    hide_hidden = true, -- only works on Windows for hidden files/directories
                    hide_by_name = {
                        -- "node_modules"
                    },
                    hide_by_pattern = { -- uses glob style patterns
                        -- "*.meta",
                        -- "*/src/*/tsconfig.json",
                    },
                    always_show = { -- remains visible even if other settings would normally hide it
                        ".gitignore",
                        ".git"
                    },
                    never_show = { -- remains hidden even if visible is toggled to true, this overrides always_show
                        -- ".DS_Store",
                        -- "thumbs.db"
                    },
                    never_show_by_pattern = { -- uses glob style patterns
                        -- ".null-ls_*",
                    }
                },
                follow_current_file = false,
                group_empty_dirs = false,
                hijack_netrw_behavior = "disabled",
                use_libuv_file_watcher = false, -- This will use the OS level file watchers to detect changes
                -- instead of relying on nvim autocmd events.
                window = {
                    mappings = {
                        ["<bs>"] = "navigate_up",
                        ["."] = "set_root",
                        ["H"] = "toggle_hidden",
                        ["/"] = "fuzzy_finder",
                        ["D"] = "fuzzy_finder_directory",
                        ["f"] = "filter_on_submit",
                        ["<c-x>"] = "clear_filter",
                        ["[g"] = "prev_git_modified",
                        ["]g"] = "next_git_modified"
                    }
                }
            },
            buffers = {
                follow_current_file = true,
                group_empty_dirs = false,
                show_unloaded = true,
                window = {
                    mappings = {
                        ["bd"] = "buffer_delete",
                        ["<bs>"] = "navigate_up",
                        ["."] = "set_root"
                    }
                }
            },
            git_status = {
                window = {
                    position = "float",
                    mappings = {
                        ["A"] = "git_add_all",
                        ["gu"] = "git_unstage_file",
                        ["ga"] = "git_add_file",
                        ["gr"] = "git_revert_file",
                        ["gc"] = "git_commit",
                        ["gp"] = "git_push",
                        ["gg"] = "git_commit_and_push"
                    }
                }
            }
        }) -- End setup Neotree
    end

  -- ##########################
  -- ######## textcase ########
  -- ##########################
  local textcase_ok, textcase = pcall(require, "textcase")
  if not textcase_ok then
    vim.notify("Require textcase", "error")
    return
  end

  textcase.setup()
end

return M
