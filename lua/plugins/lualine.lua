local function showFileSpecificInfo()
  if vim.bo.filetype == "markdown" then
    return string.format(" %s", tostring(vim.fn.wordcount().words))
  elseif
      vim.bo.filetype == "python"
      or vim.bo.filetype == "typescript"
      or vim.bo.filetype == "javascript"
      or vim.bo.filetype == "go"
      or vim.bo.filetype == "rust"
  then
    return string.format("🍪 %s", tostring(number_of_lines))
  end

  return "🍜"
end

return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function()
    local icons = require("config").icons

    return {
      options = {
        icons_enabled = true,
        theme = "tokyonight",
        globalstatus = true,
        disabled_filetypes = { statusline = { "dashboard", "alpha" } },
        component_separators = {
          left = "•",
          right = "•",
        },
        section_separators = {
          left = "",
          right = "",
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch" },
        lualine_c = {
          {
            "diagnostics",
            symbols = {
              error = icons.diagnostics.Error,
              warn = icons.diagnostics.Warn,
              info = icons.diagnostics.Info,
              hint = icons.diagnostics.Hint,
            },
          },
          -- { "filename", path = 0, symbols = { modified = "  ", readonly = "", unnamed = "" } },
          -- {
          --   "tabs",
          --   mode = 1,
          --   fmt = function(name, context)
          --     -- Show + if buffer is modified in tab
          --     local buflist = vim.fn.tabpagebuflist(context.tabnr)
          --     local winnr = vim.fn.tabpagewinnr(context.tabnr)
          --     local bufnr = buflist[winnr]
          --     local mod = vim.fn.getbufvar(bufnr, "&mod")

          --     return name .. (mod == 1 and "  " or "")
          --   end,
          -- },
        },
        lualine_x = {
          { "filetype", separator = "•", padding = { left = 1, right = 1 } },
          -- {
          --   require("lazy.status").updates,
          --   cond = require("lazy.status").has_updates,
          -- },
          {
            "diff",
            symbols = {
              added = icons.git.added,
              modified = icons.git.modified,
              removed = icons.git.removed,
            },
          },
        },
        lualine_y = {
          {
            showFileSpecificInfo,
          },
        },
        lualine_z = {
          { "location", padding = { left = 0, right = 1 } },
        },
      },
      extensions = { "neo-tree", "lazy" },
    }
  end,
}
