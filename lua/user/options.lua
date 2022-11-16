vim.opt.backup = false
vim.opt.writebackup = false

vim.opt.fileencoding = "utf-8"

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.mouse = "a"
vim.opt.hlsearch = false
vim.opt.scrolloff = 20
vim.opt.linebreak = true

-- Use the colors set in terminal configuration -> NO
-- vim.o.background = "dark"
-- vim.o.termguicolors = true
-- vim.g.colors_name = "default_theme"
vim.opt.termguicolors = true

-- vim.o.syntax = 'on'
-- vim.o.errorbells = false
-- vim.o.showmode = false
-- vim.bo.swapfile = false
-- vim.o.undodir = vim.fn.stdpath('config') .. '/undodir'
-- vim.o.undofile = true
-- vim.o.incsearch = true
vim.opt.hidden = false
-- vim.o.completeopt = 'menuone,noinsert,noselect'
-- vim.bo.autoindent = true
-- vim.bo.smartindent = true

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

vim.wo.wrap = true
-- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
-- delays and poor user experience.
vim.o.updatetime = 300
-- Always show the signcolumn, otherwise it would shift the text each time
-- diagnostics appear/become resolved.
vim.opt.signcolumn = "yes"
local signs = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " "
}
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, {
        text = icon,
        texthl = hl,
        numhl = hl
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

vim.notify = require("notify")

-- Invisible chars
vim.opt.list = true
vim.opt.listchars:append "space:⋅"

-- Clipboard management
vim.api.nvim_set_option("clipboard", "unnamed")

-- Diagnostic
local _border = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"}
vim.diagnostic.config({
    virtual_text = false,
    severity_sort = true,
    float = {
        border = _border,
        source = "always"
    }
})

local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = _border
    opts.source = "always"
    return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

-- Show line diagnostic on hover
-- vim.opt.updatetime = 250
-- vim.cmd [[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]
