vim.o.backup = false
vim.o.writebackup = false

vim.opt.fileencoding = "utf-8"

-- Use the colors set in terminal configuration -> NO
-- vim.o.termguicolors = true

-- vim.o.syntax = 'on'
-- vim.o.errorbells = false
-- vim.o.smartcase = true
-- vim.o.showmode = false
-- vim.bo.swapfile = false
-- vim.o.undodir = vim.fn.stdpath('config') .. '/undodir'
-- vim.o.undofile = true
-- vim.o.incsearch = true
-- vim.o.hidden = true
-- vim.o.completeopt = 'menuone,noinsert,noselect'
-- vim.bo.autoindent = true
-- vim.bo.smartindent = true

-- TAB = 2 spaces
vim.o.tabstop = 2

-- convert TAB to spaces
vim.opt.expandtab = true

-- vim.o.softtabstop = 2
-- vim.o.shiftwidth = 2
-- vim.o.expandtab = true

-- Enable relative line number
vim.wo.number = true
vim.wo.relativenumber = true

-- highlight the current line
vim.opt.cursorline = true

-- vim.wo.signcolumn = 'yes'
-- vim.wo.wrap = false
-- vim.wo.wrap = false

vim.wo.wrap = true
-- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
-- delays and poor user experience.
vim.o.updatetime = 300
-- Always show the signcolumn, otherwise it would shift the text each time
-- diagnostics appear/become resolved.
vim.opt.signcolumn = "yes"

-- Hide mode because shown in Lualine
vim.opt.showmode = false


-- Disable netrw at the very start of your init.lua
vim.g.loaded = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_perl_provider = 0
