local status_ok, indent_blankline = pcall(require, "indent_blankline")
if not status_ok then
    return
end

vim.cmd [[highlight IndentBlanklineIndent1 guifg=#bb9af7 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent2 guifg=#7aa2f7 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent3 guifg=#2ac3de gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent4 guifg=#7dcfff gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent5 guifg=#e0af68 gui=nocombine]]
vim.cmd [[highlight IndentBlanklineIndent6 guifg=#f7768e gui=nocombine]]

indent_blankline.setup {
    -- char = "┊",
    show_end_of_line = true,
    space_char_blankline = " ",
    -- show_current_context = true,
    show_current_context_start = true,
    -- show_trailing_blankline_indent = false,
    char_highlight_list = {"IndentBlanklineIndent1", "IndentBlanklineIndent2", "IndentBlanklineIndent3",
                           "IndentBlanklineIndent4", "IndentBlanklineIndent5", "IndentBlanklineIndent6"}
}
