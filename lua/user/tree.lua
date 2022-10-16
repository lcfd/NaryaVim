local status_ok, tree = pcall(require, "nvim-tree")
if not status_ok then
    return
end

tree.setup({
    hijack_directories = {
        enable = true,
        auto_open = true
    },
    filters = {
        dotfiles = false,
        custom = {"^.git$"}
    }
})
