local M = {}

function M.setup()

    local status_ok, treesitter = pcall(require, "nvim-treesitter.configs")
    if not status_ok then
        return
    end

    treesitter.setup {
        ensure_installed = {
            "python",
            "html",
            "json",
            "javascript",
            "dockerfile",
            "ruby",
            "rust",
            "scss",
            "sql",
            "lua",
            "typescript",
            "yaml",
            "astro",
            "markdown"
        },

        highlight = {
            -- `false` will disable the whole extension
            enable = true

        },

        -- Install parsers synchronously (only applied to `ensure_installed`)
        sync_install = false,

        -- Automatically install missing parsers when entering buffer
        auto_install = true,

        -- List of parsers to ignore installing (for "all")
        -- ignore_install = {"javascript"},

        context_commentstring = {
            enable = true,
            enable_autocmd = false
        },

        rainbow = {
            enable = true,
            extended_mode = false,
            max_file_lines = nil
        },

        autopairs = {
            enable = true
        },

        autotag = {
            enable = true
        },

        indent = {
            enable = false
        },

        move = {
            enable = true,
            set_jumps = true, -- whether to set jumps in the jumplist
            goto_next_start = {
                [']m'] = '@function.outer',
                [']]'] = '@class.outer'
            },
            goto_next_end = {
                [']M'] = '@function.outer',
                [']['] = '@class.outer'
            },
            goto_previous_start = {
                ['[m'] = '@function.outer',
                ['[['] = '@class.outer'
            },
            goto_previous_end = {
                ['[M'] = '@function.outer',
                ['[]'] = '@class.outer'
            }
        }
    }


    local status_ok, treesitter_context = pcall(require, "treesitter-context")
    if not status_ok then
        return
    end

    treesitter_context.setup()
end

return M
