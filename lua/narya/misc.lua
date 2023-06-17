local M = {}

function M.setup(config)
  -- #########################
  -- ######## Comment ########
  -- #########################

  local status_ok, comment = pcall(require, "Comment")
  if not status_ok then
    vim.notify("Require Comment", "error")
    return
  end

  comment.setup({
    toggler = {
      ---Line-comment toggle keymap
      line = "<leader>1",
      ---Block-comment toggle keymap
      block = "<leader>2",
    },
    opleader = {
      ---Line-comment keymap
      line = "<leader>1",
      ---Block-comment keymap
      block = "<leader>2",
    },
  })

  -- ########################
  -- ######## Neogit ########
  -- ########################

  local status_ok, neogit = pcall(require, "neogit")
  if not status_ok then
    vim.notify("Require Neogit", "error")
    return
  end

  neogit.setup({
    commit_popup = {
      kind = "split",
    },
  })

  -- ###################################
  -- ######## nvim-web-devicons ########
  -- ###################################

  local status_ok, webicons = pcall(require, "nvim-web-devicons")
  if not status_ok then
    vim.notify("Require nvim-web-devicons", "error")
    return
  end

  webicons.setup()

  -- ########################
  -- ######## Notify ########
  -- ########################

  local status_ok, notify = pcall(require, "notify")
  if not status_ok then
    vim.notify("Require notify", "error")
    return
  end

  notify.setup({
    stages = "static",
  })

  local status_ok, surround = pcall(require, "surround")
  if not status_ok then
    vim.notify("Require surround", "error")
    return
  end

  surround.setup({
    mappings_style = "sandwich",
    prefix = "<leader>h",
  })

  -- ##########################
  -- ######## zen mode ########
  -- ##########################
  -- require("zen-mode").setup({
  --   window = {
  --     width = 90,
  --     options = {
  --       number = true,
  --       relativenumber = true,
  --     },
  --   },
  -- })

  -- ##########################
  -- ######## textcase ########
  -- ##########################
  local textcase_ok, textcase = pcall(require, "textcase")
  if not textcase_ok then
    vim.notify("Require textcase.", "error")
    return
  end

  textcase.setup()
end

return M
