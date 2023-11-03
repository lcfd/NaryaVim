local M = {}

function M.setup()
  -- Set <space> as the leader key
  vim.g.mapleader = " "

  -- Keymaps for better default experience
  vim.keymap.set({
    "n",
    "v",
  }, "<Space>", "<Nop>")

  vim.opt.hlsearch = false
  vim.opt.backup = false
  vim.opt.writebackup = false

  vim.opt.fileencoding = "utf-8"

  -- Case insensitive searching UNLESS /C or capital in search
  vim.opt.ignorecase = true
  vim.opt.smartcase = true

  vim.opt.mouse = "a"
  vim.opt.scrolloff = 20
  vim.opt.linebreak = true

  vim.opt.completeopt = "menu,menuone,noselect"

  -- Set colorscheme
  vim.opt.termguicolors = true

  -- Save undo history
  -- vim.o.undofile = true

  vim.opt.hidden = false

  -- TAB = 2 spaces
  vim.opt.tabstop = 2
  vim.opt.shiftwidth = 2

  -- convert TAB to spaces
  vim.opt.expandtab = true

  -- vim.o.softtabstop = 2

  -- Enable relative line number
  vim.wo.number = true
  vim.wo.relativenumber = true

  -- highlight the current line
  vim.opt.cursorline = true

  -- Wrap text
  vim.wo.wrap = true

  -- Decrease update time (default: 4000)
  vim.o.updatetime = 250
  -- Always show the signcolumn, otherwise it would shift the text each time
  -- diagnostics appear/become resolved.
  vim.opt.signcolumn = "yes"

  local signs = {
    Error = "󰂧 ",
    Warn = " ",
    Hint = "󰌶 ",
    Info = " ",
  }
  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, {
      text = icon,
      texthl = hl,
      numhl = hl,
    })
  end

  -- Hide mode because shown in Lualine
  vim.opt.showmode = false

  -- Disable netrw at the very start of your init.lua
  vim.g.loaded = 1
  vim.g.loaded_netrwPlugin = 1
  vim.g.loaded_perl_provider = 0

  -- Python
  vim.g.python3_host_prog = "~/.config/nvim/venv/bin/python3"

  local notify_status_ok, notify = pcall(require, "notify")
  if not notify_status_ok then
    return
  end

  -- Invisible chars
  vim.opt.list = true
  vim.opt.listchars:append("space:⋅")

  vim.api.nvim_set_option("clipboard", "unnamedplus")

  vim.opt.loaded_node_provider = 0

  -- Diagnostic
  -- local _border = {
  --   "╭",
  --   "─",
  --   "╮",
  --   "│",
  --   "╯",
  --   "─",
  --   "╰",
  --   "│",
  -- }
  -- vim.diagnostic.config({
  --   virtual_text = false,
  --   severity_sort = true,
  --   float = {
  --     border = _border,
  --     source = "always",
  --   },
  -- })

  -- local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
  -- function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  --   opts = opts or {}
  --   opts.border = _border
  --   opts.source = "always"
  --   return orig_util_open_floating_preview(contents, syntax, opts, ...)
  -- end
end

return M
