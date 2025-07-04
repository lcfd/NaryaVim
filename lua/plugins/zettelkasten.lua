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
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended
    lazy = true,
    ft = "markdown",
    cmd = {
      "ObsidianOpen",
      "ObsidianQuickSwitch",
      "ObsidianNew",
      "ObsidianSearch",
      "ObsidianTemplate",
      "ObsidianToday",
      "ObsidianTomorrow",
      "ObsidianYesterday",
      "ObsidianTags",
      "ObsidianDailies",
      "ObsidianTemplate",
      "ObsidianWorkspace",
      "ObsidianPasteImg",
      "ObsidianNewFromTemplate",
      "ObsidianTOC",

    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
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

      mappings = {
        -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
        -- ["gf"] = {
        --   action = function()
        --     return require("obsidian").util.gf_passthrough()
        --   end,
        --   opts = { noremap = false, expr = true, buffer = true },
        -- },
        -- Toggle check-boxes.
        ["<leader>tt"] = {
          action = function()
            return require("obsidian").util.toggle_checkbox()
          end,
          opts = { buffer = true, desc = "[Obsidian] Toggle checkbox." },
        },
      },

      attachments = {
        img_folder = "attachments", -- This is the default
        -- A function that determines the text to insert in the note when pasting an image.
        -- It takes two arguments, the `obsidian.Client` and an `obsidian.Path` to the image file.
        -- This is the default implementation.
        ---@param client obsidian.Client
        ---@param path obsidian.Path the absolute path to the image file
        ---@return string
        img_text_func = function(client, path)
          local link_path
          local vault_relative_path = client:vault_relative_path(path)
          if vault_relative_path ~= nil then
            -- Use relative path if the image is saved in the vault dir.
            link_path = vault_relative_path
          else
            -- Otherwise use the absolute path.
            link_path = tostring(path)
          end
          local display_name = vim.fs.basename(link_path)
          return string.format("![%s](%s)", display_name, link_path)
        end,
      },

      -- Optional, customize how note IDs are generated given an optional title.
      ---@param title string|?
      ---@return string
      note_id_func = function(title)
        -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
        -- In this case a note with the title 'My new note' will be given an ID that looks
        -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
        local suffix = ""
        if title ~= nil then
          -- If title is given, transform it into valid file name.
          suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
          -- suffix = title:gsub("[^A-Za-z0-9-]", "")
        else
          -- If title is nil, just add 4 random uppercase letters to the suffix.
          for _ = 1, 4 do
            suffix = tostring(os.time()) .. "-" .. suffix .. string.char(math.random(65, 90))
          end
        end
        return suffix
      end,

      -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
      -- URL it will be ignored but you can customize this behavior here.
      ---@param url string
      follow_url_func = function(url)
        -- Open the URL in the default web browser.
        vim.fn.jobstart({ "open", url }) -- Mac OS
        -- vim.fn.jobstart({"xdg-open", url})  -- linux
      end,
    },
  },
}
