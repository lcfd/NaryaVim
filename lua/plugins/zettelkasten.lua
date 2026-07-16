local options_ok, options = pcall(require, "options")

local get_workspaces = function(ok, o)
  if ok then
    return o.OBSIDIAN_WORKSPACES
  else
    return {
      {
        name = "buf-parent",
        path = function()
          return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
        end,
      },
    }
  end
end

return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      legacy_commands = false,
      workspaces = get_workspaces(options_ok, options),
      templates = {
        subdir = "templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },

      daily_notes = {
        folder = "daily",
        -- Optional, if you want to change the date format for the ID of daily notes.
        date_format = "%Y-%m-%d",
        -- Optional, if you want to change the date format of the default alias of daily notes.
        alias_format = "%B %-d, %Y",
        -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
        template = "daily.md",
      },

      keys = {
        {
          "<leader>tt",
          function()
            require("obsidian").util.toggle_checkbox()
          end,
          desc = "[Obsidian] Toggle checkbox.",
        },
      },
    },
  },
}
