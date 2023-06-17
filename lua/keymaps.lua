local M = {}

function M.setup(config)
  local keyset = vim.keymap.set

  local status_ok, tsbuiltin = pcall(require, "telescope.builtin")
  if not status_ok then
    return
  end

  -- ########################
  -- ####### Generic ########
  -- ########################

  -- Avoid press shift to type :
  keyset("n", ";", ":")

  -- Go to the start and the end of a sentence
  keyset("n", "H", "^", {
    desc = "Go to the start of the line.",
  })

  keyset("n", "L", "$", {
    desc = "Go to the end of the line.",
  })

  -- Windows
  keyset("n", "<leader>ws", "<C-W><C-V>", {
    desc = "Split vertically.",
  })

  keyset("n", "<leader>e", "<C-W><Right>", {
    desc = "Move cursor to Nth window right of current one.",
  })

  keyset("n", "<leader>q", "<C-W><Left>", {
    desc = "Move cursor to Nth left right of current one.",
  })
  -- ##############################
  -- ####### telescope.nvim #######
  -- ##############################

  keyset("n", "<leader><space>", tsbuiltin.find_files, {
    desc = "Lists files in your current working directory, respects .gitignore (find_files).",
  })

  keyset("n", "<leader>fw", tsbuiltin.live_grep, {
    desc = "Search for a string in your current working directory and get results live as you type, respects .gitignore (live_grep)",
  })

  keyset("n", "<leader>fg", tsbuiltin.grep_string, {
    desc = "Searches for the string under your cursor in your current working directory (grep_string).",
  })

  keyset("n", "<leader>fb", tsbuiltin.buffers, {
    desc = "Lists open buffers in current Neovim instance (buffers).",
  })

  keyset("n", "<leader>fh", tsbuiltin.help_tags, {
    desc = "Lists available help tags and opens a new window with the relevant help info on <CR> (help_tags)",
  })

  keyset("n", "<leader>fi", tsbuiltin.current_buffer_fuzzy_find, {
    desc = "Live fuzzy search inside of the currently open buffer (current_buffer_fuzzy_find)",
  })

  keyset("n", "<leader>fo", tsbuiltin.oldfiles, {
    desc = "Lists previously open files.",
  })

  keyset("v", "<leader>s", "y<ESC>:Telescope live_grep default_text=<c-r>0<CR>", {
    desc = "Search selected text with grep.",
  })

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

  -- Text case
  --
  keyset("n", "ga.", "<cmd>TextCaseOpenTelescope<CR>", { desc = "Telescope" })
  keyset("v", "ga.", "<cmd>TextCaseOpenTelescope<CR>", { desc = "Telescope" })

  -- ####################################
  -- ######## Diagnostic keymaps ########
  -- ####################################

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

  -- Project
  keyset("n", "<leader>pp", "<CMD>lua require'telescope'.extensions.project.project{}<CR>", {
    desc = "Switch between projects.",
  })

  -- #########################
  -- ########## DAP ##########
  -- #########################

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

  -- ###########################
  -- ######## Neotree ########
  -- ###########################

  -- if config.neo_tree_enabled then
  --   keyset("n", "\\", "<cmd>Neotree reveal toggle<cr>", {
  --     desc = "Reveal Neotree",
  --   })
  -- end

  -- ##############################
  -- ####### Delete buffers #######
  -- ##############################

  keyset("n", "<leader>xx", "<cmd>bd<cr>", {
    desc = "Close the current buffer.",
  })
  keyset("n", "<leader>xa", "<cmd>%bd|e#<cr>", {
    desc = "Close all buffer apart the current one.",
  })

  -- ###############################
  -- ####### comments.nvim #########
  -- ###############################

  -- Look at lua/user/comment.lua

  -- ###############################
  -- ####### bufferline.nvim #######
  -- ###############################

  -- I don't have more than 3 buffer opened usually so I can cycle using `m`

  -- ######################
  -- ####### Neogit #######
  -- ######################

  keyset("n", "<leader>gg", "<CMD>Neogit<CR>", {
    desc = "Open the Git panel.",
  })

  -- ###############################
  -- ####### Tests (neotest) #######
  -- ###############################

  keyset("n", "<leader>rt", "<cmd>lua require('neotest').run.run()<CR>")

  -- #####################
  -- ####### Quick #######
  -- #####################

  keyset("i", "jj", "<Esc>", {
    desc = "Map esc to jj in Insert Mode.",
  })

  keyset("n", "m", "<cmd>bprevious<cr>", {
    desc = "Go to the next buffer.",
  })

  keyset("n", "M", "<cmd>bnext<cr>", {
    desc = "Go to the next buffer.",
  })

  keyset("", "xx", "<cmd>bd<cr>", {
    desc = "Close the current buffer.",
  })

  keyset("n", "<C-j>", "<cmd>w<cr>", {
    desc = "Save current buffer",
  })

  -- ##############################
  -- ####### Text-case.nvim #######
  -- ##############################

  keyset("n", "gal", "<cmd>lua require('textcase').current_word('to_lower_case')<CR>")
  keyset("n", "gas", "<cmd>lua require('textcase').current_word('to_snake_case')<CR>")
  keyset("n", "gad", "<cmd>lua require('textcase').current_word('to_dash_case')<CR>")
  keyset("n", "gan", "<cmd>lua require('textcase').current_word('to_constant_case')<CR>")
  keyset("n", "gad", "<cmd>lua require('textcase').current_word('to_dot_case')<CR>")
  keyset("n", "gaa", "<cmd>lua require('textcase').current_word('to_phrase_case')<CR>")
  keyset("n", "gac", "<cmd>lua require('textcase').current_word('to_camel_case')<CR>")
  keyset("n", "gap", "<cmd>lua require('textcase').current_word('to_pascal_case')<CR>")
  keyset("n", "gat", "<cmd>lua require('textcase').current_word('to_title_case')<CR>")
  keyset("n", "gaf", "<cmd>lua require('textcase').current_word('to_path_case')<CR>")

  keyset("n", "gaU", "<cmd>lua require('textcase').lsp_rename('to_upper_case')<CR>")
  keyset("n", "gaL", "<cmd>lua require('textcase').lsp_rename('to_lower_case')<CR>")
  keyset("n", "gaS", "<cmd>lua require('textcase').lsp_rename('to_snake_case')<CR>")
  keyset("n", "gaD", "<cmd>lua require('textcase').lsp_rename('to_dash_case')<CR>")
  keyset("n", "gaN", "<cmd>lua require('textcase').lsp_rename('to_constant_case')<CR>")
  keyset("n", "gaD", "<cmd>lua require('textcase').lsp_rename('to_dot_case')<CR>")
  keyset("n", "gaA", "<cmd>lua require('textcase').lsp_rename('to_phrase_case')<CR>")
  keyset("n", "gaC", "<cmd>lua require('textcase').lsp_rename('to_camel_case')<CR>")
  keyset("n", "gaP", "<cmd>lua require('textcase').lsp_rename('to_pascal_case')<CR>")
  keyset("n", "gaT", "<cmd>lua require('textcase').lsp_rename('to_title_case')<CR>")
  keyset("n", "gaF", "<cmd>lua require('textcase').lsp_rename('to_path_case')<CR>")

  keyset("n", "geu", "<cmd>lua require('textcase').operator('to_upper_case')<CR>")
  keyset("n", "gel", "<cmd>lua require('textcase').operator('to_lower_case')<CR>")
  keyset("n", "ges", "<cmd>lua require('textcase').operator('to_snake_case')<CR>")
  keyset("n", "ged", "<cmd>lua require('textcase').operator('to_dash_case')<CR>")
  keyset("n", "gen", "<cmd>lua require('textcase').operator('to_constant_case')<CR>")
  keyset("n", "ged", "<cmd>lua require('textcase').operator('to_dot_case')<CR>")
  keyset("n", "gea", "<cmd>lua require('textcase').operator('to_phrase_case')<CR>")
  keyset("n", "gec", "<cmd>lua require('textcase').operator('to_camel_case')<CR>")
  keyset("n", "gep", "<cmd>lua require('textcase').operator('to_pascal_case')<CR>")
  keyset("n", "get", "<cmd>lua require('textcase').operator('to_title_case')<CR>")
  keyset("n", "gef", "<cmd>lua require('textcase').operator('to_path_case')<CR>")

  -- zk
  local zk_opts = { noremap = true, silent = false }
  zk_commands = require("zk.commands")
  keyset("n", "zkd", function()
    zk_commands.get("ZkNew")({ dir = "daily" })
  end, zk_opts)

  keyset("n", "zkn", function()
    zk_commands.get("ZkNew")({ title = vim.fn.input("Title: ") })
  end, zk_opts)

  keyset("n", "zkr", function()
    zk_commands.get("ZkNotes")({ sort = { "random" }, limit = 1 })
    -- lucky = "zk list --quiet --format full --sort random --limit 1"
  end, zk_opts)
  keyset("n", "<leader>zl", "<Cmd>Telescope zk notes<CR>")
  keyset("n", "<leader>zt", "<Cmd>Telescope zk tags<CR>")
end

return M