local M = {}
function M.setup()
  vim.api.nvim_create_user_command("CopyPath", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    vim.notify('Copied "' .. path .. '" to the clipboard!')
  end, {})

  --
  -- Ops
  --

  local runDeploy = function()
    vim.fn.system({ "sh", "deploy.sh" })
  end

  vim.api.nvim_create_user_command("RunDeploy", runDeploy, {})
end

return M
