local safe_import = require("utils.safe_import")

return function(_, bufnr)
  local tsbuiltin = safe_import("telescope.builtin")

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

  nmap("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
  nmap("gd", tsbuiltin.lsp_definitions, "[G]oto [D]efinition")
  nmap("gi", vim.lsp.buf.implementation, "[G]oto [I]mplementation")
  nmap("gr", tsbuiltin.lsp_references, "[G]oto [R]eferences")
  nmap("gt", "<cmd>lua vim.lsp.buf.type_definition()<cr>", "[G]oto [T]ype")
  nmap("<leader>ds", tsbuiltin.lsp_document_symbols, "[D]ocument [S]ymbols")
  nmap("<leader>ws", tsbuiltin.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
  nmap(
    "<leader>li",
    tsbuiltin.lsp_implementations,
    "Goto the implementation of the word under the cursor if there's only one, otherwise show all options in Telescope."
  )
  nmap("K", vim.lsp.buf.hover, "Hover Documentation")
  nmap("<C-k>", vim.lsp.buf.signature_help, "Signature Documentation")
end
