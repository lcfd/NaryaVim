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

  HandleURL = function()
    local url = string.match(vim.fn.getline("."), "[a-z]*://[^ >,;]*")
    if url ~= "" then
      vim.cmd("exec \"!open '" .. url .. "'\"")
    else
      vim.cmd('echo "No URI found in line."')
    end
  end

  vim.api.nvim_create_user_command("OpenLink", HandleURL, {})

  local getStatus = function()
    local output = vim.fn.system("trak status -s")
    print(output)
  end

  vim.api.nvim_create_user_command("TrakStatus", getStatus, {})

  --
  -- ZK
  --

  local zkdaily = function()
    require("zk.commands").get("ZkNew")({ dir = "daily" })
  end

  local zkcall = function()
    require("zk.commands").get("ZkNew")({ dir = "calls", title = vim.fn.input("Customer/Topic: ") })
  end

  local zkevergreen = function()
    require("zk.commands").get("ZkNew")({ dir = "evergreen", title = vim.fn.input("Readable title: ") })
  end

  local zkatomic = function()
    require("zk.commands").get("ZkNew")({ dir = "atomic", title = vim.fn.input("Readable title: ") })
  end

  local zkfleeting = function()
    require("zk.commands").get("ZkNew")({ dir = "fleeting" })
  end

  local zkliterature = function()
    require("zk.commands").get("ZkNew")({ dir = "literature", title = vim.fn.input("Readable title: ") })
  end

  vim.api.nvim_create_user_command("ZkNewDaily", zkdaily, {})
  vim.api.nvim_create_user_command("ZkNewCall", zkcall, {})
  vim.api.nvim_create_user_command("ZkNewEvergreen", zkevergreen, {})
  vim.api.nvim_create_user_command("ZkNewAtomic", zkatomic, {})
  vim.api.nvim_create_user_command("ZkNewFleeting", zkfleeting, {})
  vim.api.nvim_create_user_command("ZkNewLiterature", zkliterature, {})
end

return M
