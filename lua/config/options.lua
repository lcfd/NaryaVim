local M = {}
function M.setup()
  -- This file is automatically loaded by plugins.core
  vim.g.mapleader = " "
  vim.g.maplocalleader = "\\"

  local opt = vim.opt

  opt.autowrite = true -- Enable auto write
  opt.hlsearch = false
  opt.clipboard = "unnamedplus" -- Sync with system clipboard
  opt.completeopt = "menu,menuone,noselect"
  opt.conceallevel = 2 -- Hide * markup for bold and italic
  opt.confirm = true -- Confirm to save changes before exiting modified buffer
  opt.cursorline = true -- Enable highlighting of the current line
  opt.expandtab = true -- Use spaces instead of tabs
  opt.formatoptions = "jcroqlnt" -- tcqj
  opt.grepformat = "%f:%l:%c:%m"
  opt.grepprg = "rg --vimgrep"
  opt.ignorecase = true -- Ignore case
  opt.inccommand = "nosplit" -- preview incremental substitute
  opt.laststatus = 3 -- global statusline
  opt.list = true -- Show some invisible characters (tabs...
  opt.mouse = "a" -- Enable mouse mode
  opt.number = true -- Print line number
  opt.pumblend = 10 -- Popup blend
  opt.pumheight = 10 -- Maximum number of entries in a popup
  opt.relativenumber = true -- Relative line numbers
  opt.scrolloff = 4 -- Lines of context
  opt.sessionoptions = {
    "buffers",
    "curdir",
    "tabpages",
    "winsize",
    "help",
    "globals",
    "skiprtp",
    "folds",
  }
  opt.shiftround = true -- Round indent
  opt.shiftwidth = 2 -- Size of an indent
  opt.shortmess:append({
    W = true,
    I = true,
    c = true,
    C = true,
  })
  opt.showmode = false -- Dont show mode since we have a statusline
  opt.sidescrolloff = 8 -- Columns of context
  opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
  opt.smartcase = true -- Don't ignore case with capitals
  opt.smartindent = true -- Insert indents automatically
  opt.spelllang = {
    "en",
  }
  opt.splitbelow = true -- Put new windows below current
  opt.splitkeep = "screen"
  opt.splitright = true -- Put new windows right of current
  opt.tabstop = 2 -- Number of spaces tabs count for
  opt.termguicolors = true -- True color support
  opt.timeoutlen = 300
  opt.undofile = true
  opt.undolevels = 10000
  opt.updatetime = 200 -- Save swap file and trigger CursorHold
  opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
  opt.wildignorecase = true
  opt.wildmode = "list:full" -- Command-line completion mode
  opt.wildoptions = "fuzzy" -- Enable fuzzy search in command-line
  opt.winminwidth = 5 -- Minimum window width
  opt.wrap = true -- Disable line wrap

  -- Fold
  opt.foldcolumn = "0" -- '0' is not bad
  opt.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
  opt.foldlevelstart = 99
  opt.foldenable = true

  if vim.fn.has("nvim-0.10") == 1 then
    opt.smoothscroll = true
  end

  -- Fix markdown indentation settings
  vim.g.markdown_recommended_style = 0
end

return M
