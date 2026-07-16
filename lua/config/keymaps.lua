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
  -- LSP
  --

  keyset("n", "<leader>rn", vim.lsp.buf.rename, { desc = "[LSP] [R]e[n]ame" })
  keyset("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "[LSP] [C]ode [A]ction" })

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
end

return M
