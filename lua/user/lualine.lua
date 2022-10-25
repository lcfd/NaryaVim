local status_ok, lualine = pcall(require, "lualine")
if not status_ok then
    return
end

local function getWords()
    if vim.bo.filetype == "markdown" then
        return string.format("✍️  %s", tostring(vim.fn.wordcount().words))
    end

    return "• 🍜 •"
end

lualine.setup {
    options = {
        icons_enabled = true,
        theme = 'tokyonight',
        component_separators = {
            left = '• 🍜 •',
            right = '• 🍜 •'
        },
        section_separators = {
            left = '',
            right = ''
        },
        disabled_filetypes = {
            statusline = {},
            winbar = {}
        },
        ignore_focus = {},
        always_divide_middle = true,
        globalstatus = true,
        refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000
        }
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        -- lualine_c = {'buffers', {
        --     'filename',
        --     path = 1
        -- }},
        lualine_c = {{
            'filename',
            newfile_status = true,
            path = 1
        }},
        -- lualine_c = {'g:coc_status'},
        -- lualine_x = {'encoding', 'fileformat', 'filetype'},
        -- lualine_x = {'encoding', 'filetype'},
        lualine_x = {'filetype'},
        -- lualine_y = {'progress'},
        lualine_y = {{getWords}},
        lualine_z = {'location'}
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {'filename'},
        lualine_x = {'location'},
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {}
}
