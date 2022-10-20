local status_ok, null_ls = pcall(require, "null-ls")
if not status_ok then
    vim.notify("Problem with mason")
    return
end

local status_ok, mason_null_ls = pcall(require, "mason-null-ls")
if not status_ok then
    vim.notify("Problem with mason")
    return
end

null_ls.setup({
    sources = {null_ls.builtins.formatting.stylua, null_ls.builtins.formatting.black,
               null_ls.builtins.formatting.djlint, null_ls.builtins.formatting.prettier,
               null_ls.builtins.code_actions.eslint_d}
})

mason_null_ls.setup({
    ensure_installed = {"stylua", "black", "eslint_d", "prettier", "djlint"},
    automatic_installation = true
})
