local maxSizeFile = 5

function filename()
  local currentFile = vim.fn.split(vim.api.nvim_buf_get_name(0), "/")
  currentFile = currentFile[#currentFile]
  if vim.api.nvim_buf_get_option(0, "buftype") ~= "" then
    return currentFile
  end
  local lenSize = string.len(currentFile)
  if lenSize > maxSizeFile then
    maxSizeFile = lenSize
  end
  if maxSizeFile % 2 == 0 then
    maxSizeFile = maxSizeFile + 1
  end
  local padding = math.floor((maxSizeFile - lenSize) / 2)
  if lenSize % 2 == 0 then
    currentFile = currentFile .. " "
  end
  padding = string.rep(" ", padding)
  return padding .. currentFile .. padding
end

function harpoonFiles()
  if vim.api.nvim_buf_get_option(0, "buftype") ~= "" then
    return ""
  end
  local tabela = require("harpoon").get_mark_config()["marks"]
  local currentFile = vim.fn.split(vim.api.nvim_buf_get_name(0), "/")
  currentFile = currentFile[#currentFile]
  local ret = {}
  for key, value in pairs(tabela) do
    local file = vim.fn.split(value["filename"], "/")
    file = file[#file]
    file = file == currentFile and file .. " 👀" or file .. " "
    table.insert(ret, "  " .. key .. " " .. file)
  end
  return table.concat(ret)
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
        },
        lualine_x = {
          { "filetype", separator = "•", padding = { left = 1, right = 1 } },
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
          harpoonFiles,
        },
        lualine_z = {
          { "location", padding = { left = 0, right = 1 } },
        },
      },
      extensions = { "nvim-tree", "lazy", "mason" },
    }
  end,
}
