local M = {}

function M.setup()
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
  if not mason_lspconfig_ok then
    vim.notify("Problems with mason-lspconfig")
    return
  end

  local status_ok, tsbuiltin = pcall(require, "telescope.builtin")
  if not status_ok then
    return
  end

  local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
  if not status_ok then
    return
  end

  local on_attach = function(_, bufnr)
    -- A function that lets us more easily define mappings specific
    -- for LSP related items. It sets the mode, buffer and description for us each time.
    local nmap = function(keys, func, desc)
      if desc then
        desc = "LSP: " .. desc
      end

      vim.keymap.set("n", keys, func, {
        buffer = bufnr,
        desc = desc,
      })
    end

    nmap("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
    nmap("<leader>lr", vim.lsp.buf.rename, "Rename what's under the cursor.")
    nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

    nmap("gd", tsbuiltin.lsp_definitions, "[G]oto [D]efinition")
    nmap("gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
    nmap("gr", tsbuiltin.lsp_references, "[G]oto [R]eferences")
    nmap("<leader>ds", tsbuiltin.lsp_document_symbols, "[D]ocument [S]ymbols")
    nmap("<leader>ws", tsbuiltin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
    nmap(
      "<leader>li",
      tsbuiltin.lsp_implementations,
      "Goto the implementation of the word under the cursor if there's only one, otherwise show all options in Telescope."
    )

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
      desc = "Format current buffer with LSP",
    })
    nmap("<leader>ff", formatfunc, "Format file.")
  end

  -- nvim-cmp supports additional completion capabilities
  local capabilities = cmp_nvim_lsp.default_capabilities()

  -- Setup mason so it can manage external tooling
  mason.setup()

  -- Enable the following language servers
  local servers = {
    "lua_ls",
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
    "tailwindcss",
    "astro",
    "zk",
    "ltex",
  }

  -- Ensure the servers above are installed
  mason_lspconfig.setup({
    ensure_installed = servers,
    automatic_installation = true,
  })

  for _, lsp in ipairs(servers) do
    if lsp == "tailwindcss" then
      lspconfig[lsp].setup({
        on_attach = on_attach,
        capabilities = capabilities,
        init_options = {
          userLanguages = {
            htmldjango = "html",
          },
        },
      })
    elseif lsp == "lua_ls" then
      lspconfig[lsp].setup({
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = {
              -- Get the language server to recognize the `vim` global
              globals = { "vim" },
            },
          },
        },
      })
    elseif lsp == "ltex" then
      lspconfig[lsp].setup({
        on_attach = on_attach,
        capabilities = capabilities,
        flags = { debounce_text_changes = 300 },
        settings = {
          ltex = {
            language = "en-GB",
            additionalRules = {
              enablePickyRules = true,
              motherTongue = "it",
            },
          },
        },
      })
    else
      lspconfig[lsp].setup({
        on_attach = on_attach,
        capabilities = capabilities,
      })
    end
  end
end

return M

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
