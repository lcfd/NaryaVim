local M = {}

function M.setup()

    -- #######################
    -- ######## Theme ########
    -- #######################

    require("tokyonight").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        style = "night", -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
        light_style = "day", -- The theme is used when the background is set to light
        transparent = true, -- Enable this to disable setting the background color
        terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
        styles = {
            -- Style to be applied to different syntax groups
            -- Value is any valid attr-list value for `:help nvim_set_hl`
            comments = {
                italic = true
            },
            keywords = {
                italic = true
            },
            functions = {},
            variables = {},
            -- Background styles. Can be "dark", "transparent" or "normal"
            sidebars = "dark", -- style for sidebars, see below
            floats = "dark" -- style for floating windows
        },
        sidebars = {
            "qf",
            "help"
        }, -- Set a darker background on sidebar-like windows. For example: `["qf", "vista_kind", "terminal", "packer"]`
        -- day_brightness = 0.3, -- Adjusts the brightness of the colors of the **Day** style. Number between 0 and 1, from dull to vibrant colors
        hide_inactive_statusline = false, -- Enabling this option, will hide inactive statuslines and replace them with a thin border instead. Should work with the standard **StatusLine** and **LuaLine**.
        dim_inactive = false, -- dims inactive windows
        lualine_bold = true, -- When `true`, section headers in the lualine theme will be bold

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
        end
    })

    vim.cmd [[colorscheme tokyonight-night]]

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

    vim.cmd [[highlight IndentBlanklineIndent1 guifg=#bb9af7 gui=nocombine]]
    vim.cmd [[highlight IndentBlanklineIndent2 guifg=#7aa2f7 gui=nocombine]]
    vim.cmd [[highlight IndentBlanklineIndent3 guifg=#2ac3de gui=nocombine]]
    vim.cmd [[highlight IndentBlanklineIndent4 guifg=#7dcfff gui=nocombine]]
    vim.cmd [[highlight IndentBlanklineIndent5 guifg=#e0af68 gui=nocombine]]
    vim.cmd [[highlight IndentBlanklineIndent6 guifg=#f7768e gui=nocombine]]

    indent_blankline.setup {
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
            "IndentBlanklineIndent6"
        }
    }

    -- ############################
    -- ######## Bufferline ########
    -- ############################

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
            line = '<leader>1',
            ---Block-comment toggle keymap
            block = '<leader>2'
        },
        opleader = {
            ---Line-comment keymap
            line = '<leader>1',
            ---Block-comment keymap
            block = '<leader>2'
        }
    })

    -- ########################
    -- ######## Neogit ########
    -- ########################

    local status_ok, neogit = pcall(require, "neogit")
    if not status_ok then
        vim.notify("Require Neogit", "error")
        return
    end

    neogit.setup {
        commit_popup = {
            kind = "split"
        }
    }

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
        background_colour = "#00000090",
        stages = "static"
    })

end

return M
