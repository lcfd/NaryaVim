local status_ok, tree = pcall(require, "nvim-tree")
if not status_ok then
    return
end

tree.setup()
