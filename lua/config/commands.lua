local M = {}

function M.setup()
  vim.api.nvim_create_user_command("CopyPath", function()
    local path = vim.fn.expand("%:p")
    vim.fn.setreg("+", path)
    vim.notify('Copied "' .. path .. '" to the clipboard!')
  end, {})


  -- Replaced by gx.nvim plugin in stimpack.lua
  -- local openLink = function()
  --   local url = string.match(vim.fn.getline("."), "[a-z]*://[^ >,;]*")
  --   if url ~= "" then
  --     vim.cmd("exec \"!open '" .. url .. "'\"")
  --   else
  --     vim.cmd('echo "No URI found in line."')
  --   end
  -- end

  -- vim.api.nvim_create_user_command("OpenLink", openLink, {})

  -- local getStatus = function()
  --   local output = vim.fn.system({ "trak", "status", "-s" })
  --   vim.notify(output, "info", { title = "Trak" })
  -- end

  -- vim.api.nvim_create_user_command("TrakStatus", getStatus, {})

  --
  -- Ops
  --

  local runDeploy = function()
    vim.fn.system({ "sh", "deploy.sh" })
  end

  vim.api.nvim_create_user_command("RunDeploy", runDeploy, {})

  -- vim.api.nvim_create_user_command("Otter", function()
  --   require("otter").activate()
  -- end, {})


  -- vim.api.nvim_create_autocmd("InsertEnter", {
  --   group = vim.api.nvim_create_augroup("otter-autostart", {}),
  --   -- ...But this only runs in markdown and quarto documents
  --   pattern = { "*.md", "*.html" },
  --   callback = function()
  --     -- Get the treesitter parser for the current buffer
  --     local ok, parser = pcall(vim.treesitter.get_parser)
  --     if not ok then return end
  --
  --
  --
  --     local otter      = require("otter")
  --     local extensions = require("otter.tools.extensions")
  --     local attached   = {}
  --
  --
  --     -- Get the language for the current cursor position (this will be
  --     -- determined by the current code chunk if that's where the cursor
  --     -- is)
  --     local line, col = vim.fn.line(".") - 1, vim.fn.col(".")
  --     local lang      = parser:language_for_range({ line, col, line, col + 1 }):lang()
  --
  --     -- If otter has an extension available for that language, and if
  --     -- the LSP isn't already attached, then activate otter for that
  --     -- language
  --     if extensions[lang] and not vim.tbl_contains(attached, lang) then
  --       table.insert(attached, lang)
  --       print(lang)
  --       vim.schedule(function() otter.activate({ lang }, true, true) end)
  --     end
  --   end
  -- })

  --
  -- ZK
  --

  -- local zkdaily = function()
  --   require("zk.commands").get("ZkNew")({ dir = "daily" })
  -- end

  -- local zkcall = function()
  --   require("zk.commands").get("ZkNew")({ dir = "calls", title = vim.fn.input("Customer: ") })
  -- end

  -- local zkmeeting = function()
  --   require("zk.commands").get("ZkNew")({ dir = "meetings", title = vim.fn.input("Customer: ") })
  -- end

  -- local zkevergreen = function()
  --   require("zk.commands").get("ZkNew")({ dir = "evergreen", title = vim.fn.input("Readable title: ") })
  -- end

  -- local zkatomic = function()
  --   require("zk.commands").get("ZkNew")({ dir = "atomic", title = vim.fn.input("Readable title: ") })
  -- end

  -- local zkfleeting = function()
  --   require("zk.commands").get("ZkNew")({ dir = "fleeting" })
  -- end

  -- local zkliterature = function()
  --   require("zk.commands").get("ZkNew")({ dir = "literature", title = vim.fn.input("Readable title: ") })
  -- end

  -- vim.api.nvim_create_user_command("ZkNewDaily", zkdaily, {})
  -- vim.api.nvim_create_user_command("ZkNewCall", zkcall, {})
  -- vim.api.nvim_create_user_command("ZkNewMeeting", zkmeeting, {})
  -- vim.api.nvim_create_user_command("ZkNewEvergreen", zkevergreen, {})
  -- vim.api.nvim_create_user_command("ZkNewAtomic", zkatomic, {})
  -- vim.api.nvim_create_user_command("ZkNewFleeting", zkfleeting, {})
  -- vim.api.nvim_create_user_command("ZkNewLiterature", zkliterature, {})
end

return M
