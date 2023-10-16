local M = {}

-- From LazyVim
function M.safe_keymap_set(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  local modes = type(mode) == "string" and { mode } or mode

  ---@param m string
  modes = vim.tbl_filter(function(m)
    return not (keys.have and keys:have(lhs, m))
  end, modes)

  -- do not create the keymap if a lazy keys handler exists
  if #modes > 0 then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      ---@diagnostic disable-next-line: no-unknown
      opts.remap = nil
    end
    vim.keymap.set(modes, lhs, rhs, opts)
  end
end

function M.setup(config)
  -- local keyset = vim.keymap.set
  local keyset = M.safe_keymap_set

  local status_ok, tsbuiltin = pcall(require, "telescope.builtin")
  if not status_ok then
    return
  end

  --
  -- Generic
  --

  -- Avoid press shift to type :
  -- Not working with keyset function.
  vim.keymap.set("n", ";", ":")

  -- new file
  keyset("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

  -- Neovim Windows

  keyset("n", "|", "<C-W><C-V>", {
    desc = "Generic — Split vertically.",
  })

  keyset("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
  keyset("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

  keyset({ "n", "v" }, "<leader>ff", function()
    require("conform").format({
      lsp_fallback = true,
      async = false,
      timeout_ms = 1000,
    })
  end, { desc = "Generic — Format file or range (in visual mode)" })

  keyset("n", "<BS>", tsbuiltin.buffers, {
    desc = "Generic — Show all current buffers",
  })

  --
  -- telescope.nvim
  --

  keyset("n", "<leader><space>", tsbuiltin.find_files, {
    desc = "Telescope — Lists files in your current working directory, respects .gitignore (find_files).",
    noremap = true,
  })

  keyset("n", "<leader>fw", tsbuiltin.live_grep, {
    desc = "Telescope — Search for a string in your current working directory and get results live as you type, respects .gitignore (live_grep)",
    noremap = true,
  })

  keyset({ "n", "v" }, "<leader>fg", tsbuiltin.grep_string, {
    desc = "Telescope — Searches for the string under your cursor in your current working directory (grep_string).",
  })

  keyset("n", "<leader>fb", tsbuiltin.buffers, {
    desc = "Telescope — Lists open buffers in current Neovim instance (buffers).",
    noremap = true,
  })

  keyset("n", "<leader>fh", tsbuiltin.help_tags, {
    desc = "Telescope — Lists available help tags and opens a new window with the relevant help info on <CR> (help_tags)",
    noremap = true,
  })

  keyset("n", "<leader>fi", tsbuiltin.current_buffer_fuzzy_find, {
    desc = "Telescope — Live fuzzy search inside of the currently open buffer (current_buffer_fuzzy_find)",
    noremap = true,
  })

  keyset("n", "<leader>fo", tsbuiltin.oldfiles, {
    desc = "Telescope — Lists previously open files.",
    noremap = true,
  })

  keyset("n", "<leader>fe", tsbuiltin.symbols, {
    desc = "Telescope — Lists of emojis.",
    noremap = true,
  })

  keyset(
    "n",
    "<leader>fx",
    tsbuiltin.resume,
    { noremap = true, silent = true, desc = "Resume Telescope's last search." }
  )

  -- Text case
  keyset("n", "ga.", "<cmd>TextCaseOpenTelescope<CR>", { desc = "Telescope — Text case" })
  keyset("v", "ga.", "<cmd>TextCaseOpenTelescope<CR>", { desc = "Telescope — Text case" })

  -- ZK
  keyset("n", "<leader>zl", "<Cmd>Telescope zk notes<CR>", { desc = "Telescope — ZK notes " })
  keyset("n", "<leader>zt", "<Cmd>Telescope zk tags<CR>", { desc = "Telescope — ZK tags " })

  -- Git
  keyset("n", "<leader>gb", tsbuiltin.git_branches, {
    desc = "Lists all branches with log preview, checkout action <cr>, track action <C-t> and rebase action<C-r>.",
  })
  keyset("n", "<leader>gc", tsbuiltin.git_commits, {
    desc = "Lists git commits with diff preview, checkout action <cr>, reset mixed <C-r>m, reset soft <C-r>s and reset hard <C-r>h.",
  })
  keyset("n", "<leader>gs", tsbuiltin.git_status, {
    desc = "Lists current changes per file with diff preview and add action. (Multi-selection still WIP)",
  })

  --
  -- Diagnostic keymaps
  --

  keyset("n", "<leader>lk", function()
    tsbuiltin.diagnostics({
      bufnr = 0,
    })
  end, {
    desc = "Lists Diagnostics for all open buffers or a specific buffer. Use option bufnr=0 for current buffer.",
  })

  keyset("n", "<leader>lj", function()
    vim.diagnostic.open_float(nil, {
      focus = false,
    })
  end, {
    desc = "Diagnostic of element in hover.",
  })

  keyset("n", "[d", vim.diagnostic.goto_prev, {
    desc = "Go to previous error.",
  })

  keyset("n", "]d", vim.diagnostic.goto_next, {
    desc = "Go to next error.",
  })

  --
  -- DAP
  --

  keyset("n", "<F5>", "<cmd>lua require('dap').continue()<CR>")
  keyset("n", "<F10>", "<cmd>lua require('dap').step_over()<CR>")
  keyset("n", "<F11>", "<cmd>lua require('dap').step_into()<CR>")
  keyset("n", "<F12>", "<cmd>lua require('dap').step_out()<CR>")
  keyset("n", "<leader>b", "<cmd>lua require('dap').toggle_breakpoint()<CR>")
  keyset("n", "<leader>B", "<cmd>lua require('dap').set_breakpoint()<CR>")
  keyset("n", "<leader>dr", "<cmd>lua require('dap').repl.open()<CR>")
  keyset("n", "<leader>dl", "<cmd>lua require('dap').run_last()<CR>")
  keyset({ "n", "v" }, "<Leader>dh", "<cmd>lua require('dap.ui.widgets').hover()<CR>")
  keyset({ "n", "v" }, "<Leader>dp", "<cmd>lua require('dap.ui.widgets').preview()<CR>")
  keyset(
    "n",
    "<leader>df",
    "<cmd>lua local widgets = require('dap.ui.widgets') widgets.centered_float(widgets.frames)<CR>"
  )
  keyset(
    "n",
    "<leader>ds",
    "<cmd>lua local widgets = require('dap.ui.widgets') widgets.centered_float(widgets.scopes)<CR>"
  )

  --
  -- Neotree
  --

  -- Look at lua/plugins/neo-tree.lua

  --
  -- Delete buffers
  --

  keyset("n", "<leader>xx", "<cmd>bd<cr>", {
    desc = "Close the current buffer.",
  })
  keyset("n", "<leader>xa", "<cmd>%bd|e#<cr>", {
    desc = "Close all buffer apart the current one.",
  })

  --
  -- comments.nvim
  --

  -- Look at lua/plugins/stimpack.lua

  --
  -- bufferline.nvim
  --

  -- Absent at the moment

  --
  -- Neogit
  --

  keyset("n", "<leader>gg", "<CMD>Neogit<CR>", {
    desc = "Open the Git panel.",
  })

  --
  -- Tests (neotest)
  --

  keyset("n", "<leader>rt", "<CMD>lua require('neotest').run.run()<CR>")

  --
  -- Quick
  --

  -- Go to the start and the end of a sentence
  keyset("n", "H", "^", {
    desc = "Go to the start of the line.",
  })

  keyset("n", "L", "$", {
    desc = "Go to the end of the line.",
  })

  keyset("i", "jj", "<Esc>", {
    desc = "Map esc to jj in Insert Mode.",
  })

  --
  -- HARPOON
  --

  keyset("n", "-", "<CMD>lua require('harpoon.mark').add_file()<CR>", {
    desc = "Mark files you want to revisit later on.",
  })

  keyset("n", "=", "<CMD>lua require('harpoon.ui').toggle_quick_menu()<CR>", {
    desc = "View all project marks.",
  })

  keyset("n", "<leader>1", "<CMD>lua require('harpoon.ui').nav_file(1)<CR>", {
    desc = "Navigates to file 1.",
  })
  keyset("n", "<leader>2", "<CMD>lua require('harpoon.ui').nav_file(2)<CR>", {
    desc = "Navigates to file 2.",
  })
  keyset("n", "<leader>3", "<CMD>lua require('harpoon.ui').nav_file(3)<CR>", {
    desc = "Navigates to file 3.",
  })

  keyset("", "xx", "<CMD>bd<CR>", {
    desc = "Close the current buffer.",
  })

  keyset("n", "<C-j>", "<CMD>w<CR>", {
    desc = "Save current buffer",
  })

  --
  -- Spectre
  --

  keyset("n", "<leader>S", '<cmd>lua require("spectre").toggle()<CR>', {
    desc = "Toggle Spectre",
  })
  keyset("n", "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
    desc = "Search current word",
  })
  keyset("v", "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', {
    desc = "Search current word",
  })
  keyset("n", "<leader>sp", '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
    desc = "Search on current file",
  })

  --
  -- zk
  --

  local zk_opts = { noremap = true, silent = false }
  local zk_commands = require("zk.commands")
  keyset("n", "zkd", function()
    zk_commands.get("ZkNew")({ dir = "daily" })
  end, zk_opts)

  keyset("n", "zkn", function()
    zk_commands.get("ZkNew")({ title = vim.fn.input("Title: ") })
  end, zk_opts)

  -- lucky = "zk list --quiet --format full --sort random --limit 1"
  keyset("n", "zkr", function()
    zk_commands.get("ZkNotes")({ sort = { "random" }, limit = 1 })
  end, zk_opts)

  --
  -- SymbolsOutline
  --

  keyset("n", "<leader>cs", "<cmd>SymbolsOutline<cr>", { desc = "Symbols Outline" })
end

return M
