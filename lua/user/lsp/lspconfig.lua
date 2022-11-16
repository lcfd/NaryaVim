local lspconfig_status_ok, lspconfig = pcall(require, "lspconfig")
if not lspconfig_status_ok then
    vim.notify("Problems with lspconfig")
    return
end

-- ########################################
-- ############### HACK ###################
-- ########################################
-- Use Poetry virtualenv in the folder without activating it manually
-- *if* there is no activated virtualenv.

local path = lspconfig.util.path

local function get_python_path(workspace)
    -- Use activated virtualenv.
    if vim.env.VIRTUAL_ENV then
        return path.join(vim.env.VIRTUAL_ENV, "bin", "python")
    end

    -- Find and use virtualenv via poetry in workspace directory.
    local match = vim.fn.glob(path.join(workspace, "poetry.lock"))
    if match ~= "" then
        local venv = vim.fn.trim(vim.fn.system("poetry env info -p"))
        return path.join(venv, "bin", "python")
    end

    -- Fallback to system Python.
    return exepath("python3") or exepath("python") or "python"
end

lspconfig.pyright.setup({
    before_init = function(_, config)
        config.settings.python.pythonPath = get_python_path(config.root_dir)
    end
})

lspconfig.tailwindcss.setup({
    filetypes = {"html", "htmldjango", "django-html", "djangohtml"},
    root_dir = lspconfig.util.root_pattern("project/theme/static_src/tailwind.config.js",
        "theme/static_src/tailwind.config.js", "tailwind.config.js", "tailwind.config.ts", "postcss.config.js",
        "postcss.config.ts", "package.json", "node_modules", ".git")
})
