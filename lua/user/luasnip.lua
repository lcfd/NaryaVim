local status_ok, luasnip = pcall(require, "luasnip")
if not status_ok then
    return
end

luasnip.config.set_config({
    history = true,
    -- treesitter-hl has 100, use something higher (default is 200).
    ext_base_prio = 200,
    -- minimal increase in priority.
    ext_prio_increase = 1,
    enable_autosnippets = false
    -- store_selection_keys = "<c-s>",
})

--
-- -- luasnip.setup({})
--
-- luasnip.filetype_extend("htmldjango", {"html"})
-- luasnip.filetype_extend("html", {"htmldjango"})
luasnip.filetype_extend("python", {"django"})
--
require("luasnip.loaders.from_vscode").lazy_load({
    paths = {"./snippets"}
})
-- require("luasnip.loaders.from_vscode").lazy_load()
