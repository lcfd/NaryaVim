local status_ok, webicons = pcall(require, "nvim-web-devicons")
if not status_ok then
    return
end

webicons.setup()
