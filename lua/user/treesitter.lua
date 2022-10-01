local status_ok, treesitter = pcall(require, "nvim-treesitter.configs")
if not status_ok then
    return
end

treesitter.setup {
    ensure_installed = {"python", "html", "json", "javascript", "dockerfile", "ruby", "rust", "scss", "sql", "lua",
                        "svelte", "typescript", "yaml", "astro", "markdown"},

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    auto_install = true,

    -- List of parsers to ignore installing (for "all")
    -- ignore_install = {"javascript"},

    highlight = {
        -- `false` will disable the whole extension
        enable = true

    },
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
    }
}
