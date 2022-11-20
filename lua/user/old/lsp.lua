local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
    vim.notify("Problems with lspconfig")
    return
end

local mason_status_ok, mason = pcall(require, "mason")
if not mason_status_ok then
    vim.notify("Problems with mason")
    return
end

local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig then
    vim.notify("Problems with mason-lspconfig")
    return
end

local status_ok, tsbuiltin = pcall(require, "telescope.builtin")
if not status_ok then
    return
end

local on_attach = function(_, bufnr)
    -- NOTE: Remember that lua is a real programming language, and as such it is possible
    -- to define small helper and utility functions so you don't have to repeat yourself
    -- many times.
    --
    -- In this case, we create a function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, {
            buffer = bufnr,
            desc = desc
        })
    end

    nmap('<leader>rn', vim.lsp.buf.rename, "[R]e[n]ame")
    nmap("<leader>lr", vim.lsp.buf.rename, "Rename what's under the cursor.")
    nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

    -- nmap("gd", vim.lsp.buf.definition, "[G]oto [D]efinition")
    nmap("gd", tsbuiltin.lsp_definitions, "[G]oto [D]efinition")
    nmap("gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
    nmap("gr", tsbuiltin.lsp_references, "[G]oto [R]eferences")
    nmap("<leader>ds", tsbuiltin.lsp_document_symbols, "[D]ocument [S]ymbols")
    nmap("<leader>ws", tsbuiltin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

    -- See `:help K` for why this keymap
    nmap("K", vim.lsp.buf.hover, "Hover Documentation")
    nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")

    -- Lesser used LSP functionality
    nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
    nmap("<leader>D", vim.lsp.buf.type_definition, "Type [D]efinition")
    nmap("<leader>wa", vim.lsp.buf.add_workspace_folder, "[W]orkspace [A]dd Folder")
    nmap("<leader>wr", vim.lsp.buf.remove_workspace_folder, "[W]orkspace [R]emove Folder")
    nmap("<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "[W]orkspace [L]ist Folders")

    -- Create a command `:Format` local to the LSP buffer
    local formatfunc = function(_)
        if vim.lsp.buf.format then
            vim.lsp.buf.format()
        elseif vim.lsp.buf.formatting then
            vim.lsp.buf.formatting()
        end
    end
    vim.api.nvim_buf_create_user_command(bufnr, "Format", formatfunc, {
        desc = "Format current buffer with LSP"
    })
    nmap("<leader>df", formatfunc, "Format file.")
end

-- nvim-cmp supports additional completion capabilities

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Setup mason so it can manage external tooling
mason.setup()

-- Enable the following language servers
local servers = {
    "sumneko_lua",
    "pyright",
    "html",
    "tsserver",
    "dockerls",
    "yamlls",
    "marksman",
    "jsonls",
    "sqlls",
    "rust_analyzer",
    "lemminx",
    "taplo",
    "tailwindcss"
}

-- Ensure the servers above are installed
mason_lspconfig.setup {
    ensure_installed = servers,
    automatic_installation = true
}

-- for _, lsp in ipairs(servers) do
--     lspconfig[lsp].setup {
--         on_attach = on_attach,
--         capabilities = capabilities
--     }
-- end

-- lspconfig.pyright.setup({
--     -- before_init = function(_, config)
--     --     config.settings.python.pythonPath = get_python_path(config.root_dir)
--     -- end
--     -- on_attach = on_attach,
--     capabilities = capabilities
-- })

require('lspconfig')['pyright'].setup {
  capabilities = capabilities
}

-- lspconfig.tailwindcss.setup({
--     filetypes = {"html", "htmldjango", "django-html", "djangohtml"},
--     root_dir = lspconfig.util.root_pattern("project/theme/static_src/tailwind.config.js",
--         "theme/static_src/tailwind.config.js", "tailwind.config.js", "tailwind.config.ts", "postcss.config.js",
--         "postcss.config.ts", "package.json", "node_modules", ".git")
-- })

-- ########################################
-- ############### HACK ###################
-- ########################################
-- Use Poetry virtualenv in the folder without activating it manually
-- *if* there is no activated virtualenv.

-- local path = lspconfig.util.path

-- local function get_python_path(workspace)
--     -- Use activated virtualenv.
--     if vim.env.VIRTUAL_ENV then
--         return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
--     end

--     -- Find and use virtualenv via poetry in workspace directory.
--     local match = vim.fn.glob(path.join(workspace, "poetry.lock"))
--     if match ~= "" then
--         local venv = vim.fn.trim(vim.fn.system("poetry env info -p"))
--         return path.join(venv, "bin", "python")
--     end

--     -- Fallback to system Python.
--     return exepath("python3") or exepath("python") or "python"
-- end

