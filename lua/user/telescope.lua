local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
    return
end

telescope.setup {
    defaults = {
        file_ignore_patterns = {"node_modules", ".git", "dist", "output", ".mypy_cache", "__pycache__", "*.pyc",
                                ".jekyll-cache", "venv", "deploy/artifacts"}
    },
    pickers = {
        find_files = {
            hidden = true,
            no_ignore = true
        }
    },
    extensions = {
        file_browser = {
            -- theme = "ivy",
            hijack_netrw = false,
        }
    }
}

telescope.load_extension("file_browser")
telescope.load_extension('project')
