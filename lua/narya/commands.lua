local M = {}

function M.setup()
  vim.api.nvim_create_user_command("Cppath", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    vim.notify('Copied "' .. path .. '" to the clipboard!')
  end, {})

  vim.api.nvim_create_user_command("SetDjangoProject", function()
    vim.cmd("au BufNewFile,BufRead *.html set filetype=htmldjango")
  end, {})

  vim.api.nvim_create_user_command("OpenTelegram", function()
    -- vim.cmd("au BufNewFile,BufRead *.html set filetype=htmldjango")
    vim.cmd(":silent ! open 'telegram://resolve?domain=@Radghiv'")
  end, {})
  -- telegram://

  HandleURL = function()
    local url = string.match(vim.fn.getline("."), "[a-z]*://[^ >,;]*")
    if url ~= "" then
      vim.cmd("exec \"!open '" .. url .. "'\"")
    else
      vim.cmd('echo "No URI found in line."')
    end
  end

  vim.api.nvim_create_user_command("OpenLink", HandleURL, {})

  -- TODO: check pyproject if Django is installed -> Lua io.popopen
end

return M

-- tg://msg?text={{SOMETEXT}}&to={{GROUP_ID}}
