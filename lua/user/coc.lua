local keyset = vim.keymap.set

vim.g.coc_global_extensions = {"coc-snippets", -- Add snippets https://github.com/neoclide/coc-snippets
"coc-html", -- Html language server https://github.com/neoclide/coc-html
"coc-json", -- Json language server https://github.com/neoclide/coc-json
"coc-pyright", -- https://github.com/fannheyward/coc-pyright
"coc-htmldjango", -- https://github.com/yaegassy/coc-htmldjango
"coc-markdownlint", -- markdownlint for Neovim https://github.com/fannheyward/coc-markdownlint
"coc-sumneko-lua", -- Lua extension using sumneko lua-language-server https://github.com/xiyaowong/coc-sumneko-lua
"coc-yaml", -- Fork of vscode-yaml that works with coc.nvim https://github.com/neoclide/coc-yaml
"coc-rust-analyzer", -- rust-analyzer for Neovim https://github.com/fannheyward/coc-rust-analyzer
"coc-fish", -- Asynchronous completion source for Coc and fish. https://github.com/oncomouse/coc-fish
"@yaegassy/coc-tailwindcss3", -- https://github.com/yaegassy/coc-tailwindcss3
"coc-emoji" -- Emoji words, default enabled for markdown file only.
}

-- Auto complete
function _G.check_back_space()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s')
end

-- Highlight the symbol and its references when holding the cursor.
vim.api.nvim_create_augroup("CocGroup", {})
vim.api.nvim_create_autocmd("CursorHold", {
    group = "CocGroup",
    command = "silent call CocActionAsync('highlight')",
    desc = "Highlight symbol under cursor on CursorHold"
})

-- Setup formatexpr specified filetype(s).
vim.api.nvim_create_autocmd("FileType", {
    group = "CocGroup",
    pattern = "typescript,json",
    command = "setl formatexpr=CocAction('formatSelected')",
    desc = "Setup formatexpr specified filetype(s)."
})

-- Update signature help on jump placeholder.
vim.api.nvim_create_autocmd("User", {
    group = "CocGroup",
    pattern = "CocJumpPlaceholder",
    command = "call CocActionAsync('showSignatureHelp')",
    desc = "Update signature help on jump placeholder"
})

-- Add `:Format` command to format current buffer.
vim.api.nvim_create_user_command("Format", "call CocAction('format')", {})

-- " Add `:Fold` command to fold current buffer.
vim.api.nvim_create_user_command("Fold", "call CocAction('fold', <f-args>)", {
    nargs = '?'
})

-- Add `:OR` command for organize imports of the current buffer.
vim.api.nvim_create_user_command("OR", "call CocActionAsync('runCommand', 'editor.action.organizeImport')", {})
