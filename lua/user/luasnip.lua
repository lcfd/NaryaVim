local status_ok, luasnip = pcall(require, "luasnip")
if not status_ok then
    return
end

luasnip.setup({})

luasnip.filetype_extend("htmldjango", {"html"})
luasnip.filetype_extend("python", {"django"})

require("luasnip.loaders.from_vscode").lazy_load()
