local safe_import = require("utils.safe_import")
local M = {}

function M.safe_keymap_set(mode, lhs, rhs, opts)
  local modes = type(mode) == "string" and { mode } or mode
  vim.keymap.set(modes, lhs, rhs, opts)
end

function M.setup()
  local keyset = M.safe_keymap_set

  --
  -- Generic
  --

  -- Avoid press shift to type ":" char
  keyset("n", ";", ":", { desc = "[Stimpack] Open cmd." })

  keyset("n", "<C-j>", "<CMD>w<CR>", { desc = "[Stimpack] Save current buffer." })
  keyset("i", "jj", "<Esc>", { desc = "[Stimpack] Map esc to jj in Insert Mode." })

  -- Go to the start and the end of a sentence
  keyset("n", "H", "^", { desc = "[Stimpack] Go to the start of the line." })
  keyset("n", "L", "$", { desc = "[Stimpack] Go to the end of the line." })

  -- Neovim Windows

  keyset("n", "\\", "<C-W><C-V>", { desc = "[Window] Split vertically." })
  keyset("n", "|", "<CMD>q<CR>", { desc = "[Window] Close." })
  keyset("n", "<C-h>", "<C-w>h", { desc = "[Window] Go to left.", remap = true })
  keyset("n", "<C-l>", "<C-w>l", { desc = "[Window] Go to right.", remap = true })

  keyset({ "n", "v" }, "<leader>ff", function()
    require("conform").format({
      lsp_fallback = true,
      async = false,
      timeout_ms = 1000,
    })
  end, { desc = "[Conform] Format file (or range in visual mode)" })

  --
  -- telescope.nvim
  --

  local tsbuiltin = safe_import("telescope.builtin")
  local telescope = safe_import("telescope")

  if tsbuiltin and telescope then
    keyset("n", "<leader><space>", tsbuiltin.find_files, {
      desc = "[Telescope] Lists files in your current working directory, respects .gitignore (find_files).",
      noremap = true,
    })


    keyset("n", "<leader>fw", telescope.extensions.live_grep_args.live_grep_args, {
      desc =
      "[Telescope] Search for a string in your current working directory and get results live as you type, respects .gitignore (live_grep)",
      noremap = true,
    })

    -- Shortcut
    local live_grep_args_shortcuts = require("telescope-live-grep-args.shortcuts")
    keyset({ "n", "v" }, "<leader>fg", live_grep_args_shortcuts.grep_word_under_cursor, {
      desc = "[Telescope] Searches for the string under your cursor in your current working directory (grep_string).",
    })
    keyset({ "v" }, "<leader>fs", live_grep_args_shortcuts.grep_visual_selection, {
      desc = "[Telescope] Start live grep with visual selection.",
    })

    keyset("n", "<leader>fb", tsbuiltin.buffers, {
      desc = "[Telescope] Lists open buffers in current Neovim instance (buffers).",
      noremap = true,
    })

    keyset("n", "<leader>fh", tsbuiltin.help_tags, {
      desc =
      "[Telescope] Lists available help tags and opens a new window with the relevant help info on <CR> (help_tags)",
      noremap = true,
    })

    keyset("n", "<leader>fi", tsbuiltin.current_buffer_fuzzy_find, {
      desc = "[Telescope] Live fuzzy search inside of the currently open buffer (current_buffer_fuzzy_find)",
      noremap = true,
    })

    keyset("n", "<leader>fo", tsbuiltin.oldfiles, {
      desc = "[Telescope] Lists previously open files.",
      noremap = true,
    })

    keyset("n", "<leader>fe", tsbuiltin.symbols, {
      desc = "[Telescope] Lists of emojis.",
      noremap = true,
    })

    keyset("n", "<leader>fc", tsbuiltin.commands, {
      desc = "[Telescope] Lists commands.",
      noremap = true,
    })

    keyset(
      "n",
      "<leader>fx",
      tsbuiltin.resume,
      { noremap = true, silent = true, desc = "[Telescope] Resume last search." }
    )
  end
  -- Text case
  keyset("n", "ga.", "<cmd>TextCaseOpenTelescope<CR>", { desc = "[Telescope] Text case" })
  keyset("v", "ga.", "<cmd>TextCaseOpenTelescope<CR>", { desc = "[Telescope] Text case" })

  --
  -- Diagnostic keymaps
  --

  if tsbuiltin then
    keyset("n", "<leader>lk", function()
      tsbuiltin.diagnostics({
        bufnr = 0,
      })
    end, {
      desc = "[Diagnostics] Current buffer.",
    })
  end

  keyset("n", "<leader>lj", function()
    vim.diagnostic.open_float(nil, {
      focus = false,
    })
  end, {
    desc = "[Diagnostic] of element in hover.",
  })

  keyset("n", "[d", vim.diagnostic.goto_prev, {
    desc = "[Diagnostic] Go to previous error.",
  })

  keyset("n", "]d", vim.diagnostic.goto_next, {
    desc = "[Diagnostic] Go to next error.",
  })

  --
  -- NvimTree
  --

  -- keyset(
  --   "n",
  --   "<leader>p",
  --   "<CMD>NvimTreeToggle<CR>",
  --   { noremap = true, silent = true, desc = "[NvimTree] Toggle (cwd)" }
  -- )

  --
  -- Delete buffers
  --

  -- keyset("n", "<leader>xa", "<cmd>%bd|e#<cr>", {
  --   desc = "[Buffer] Close all but the current one.",
  -- })

  --
  -- Neotest
  --

  keyset("n", "<leader>rt", "<CMD>lua require('neotest').run.run()<CR>", { desc = "[Neotest] Run" })

  --
  -- Spectre
  --

  keyset("n", "<leader>S", '<cmd>lua require("spectre").toggle()<CR>', {
    desc = "[Spectre] Toggle.",
  })
  keyset("n", "<leader>sw", '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
    desc = "[Spectre] Search current word.",
  })
  keyset("v", "<leader>sw", '<esc><cmd>lua require("spectre").open_visual()<CR>', {
    desc = "[Spectre] Search current word.",
  })
  keyset("n", "<leader>sp", '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
    desc = "[Spectre] Search on current file.",
  })

  --
  -- DAP
  --

  -- keyset("n", "<F5>", "<cmd>lua require('dap').continue()<CR>")
  -- keyset("n", "<F10>", "<cmd>lua require('dap').step_over()<CR>")
  -- keyset("n", "<F11>", "<cmd>lua require('dap').step_into()<CR>")
  -- keyset("n", "<F12>", "<cmd>lua require('dap').step_out()<CR>")
  -- keyset("n", "<leader>b", "<cmd>lua require('dap').toggle_breakpoint()<CR>")
  -- keyset("n", "<leader>B", "<cmd>lua require('dap').set_breakpoint()<CR>")
  -- keyset("n", "<leader>dr", "<cmd>lua require('dap').repl.open()<CR>")
  -- keyset("n", "<leader>dl", "<cmd>lua require('dap').run_last()<CR>")
  -- keyset({ "n", "v" }, "<Leader>dh", "<cmd>lua require('dap.ui.widgets').hover()<CR>")
  -- keyset({ "n", "v" }, "<Leader>dp", "<cmd>lua require('dap.ui.widgets').preview()<CR>")
  -- keyset(
  --   "n",
  --   "<leader>df",
  --   "<cmd>lua local widgets = require('dap.ui.widgets') widgets.centered_float(widgets.frames)<CR>"
  -- )
  -- keyset(
  --   "n",
  --   "<leader>ds",
  --   "<cmd>lua local widgets = require('dap.ui.widgets') widgets.centered_float(widgets.scopes)<CR>"
  -- )
end

return M
