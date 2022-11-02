local status_ok, tree = pcall(require, "nvim-tree")
if not status_ok then
    return
end

tree.setup({
    view = {
        adaptive_size = true
    },
    hijack_directories = {
        enable = true,
        auto_open = true
    },
    filters = {
        dotfiles = false,
        custom = {"^.git$"}
    },
    -- respect_buf_cwd = true,
    update_focused_file = {
        enable = true,
        update_root = false,
        ignore_list = {}
    },
    hijack_cursor = true,
    diagnostics = {
        enable = true
    }
})
