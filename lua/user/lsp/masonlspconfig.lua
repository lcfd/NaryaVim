local status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status_ok then
    vim.notify("Problem with mason-lspconfig")
    return
end

local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not status_ok then
    vim.notify("Problems with lspconfig")
    return
end

local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
    return
end

mason_lspconfig.setup({
    ensure_installed = {"sumneko_lua", "pyright", "html", "tsserver", "dockerls", "yamlls", "marksman", "jsonls",
                        "sqlls", "lemminx", "taplo", "tailwindcss"},
    automatic_installation = true
})

local capabilities = cmp_nvim_lsp.default_capabilities()

-- mason_lspconfig.setup_handlers({function(server_name)
--     if server_name == "tailwindcss" then
--         lspconfig[server_name].setup({
--             capabilities = capabilities,
--             root_dir = lspconfig.util.root_pattern("tailwind.config.js", "tailwind.config.ts", "postcss.config.js",
--                 "postcss.config.ts", "package.json", "node_modules", ".git",
--                 "./project/theme/static_src/tailwind.config.js", "./theme/static_src/tailwind.config.js")
--         })
--     elseif server_name == "html" then
--         lspconfig[server_name].setup({
--             capabilities = capabilities
--             -- filetypes = {"html", "htmldjango"}
--         })
--     else
--         lspconfig[server_name].setup({
--             capabilities = capabilities
--         })
--     end
-- end})

