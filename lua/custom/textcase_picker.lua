-- Panel for text-case.nvim that doesn't depend on Telescope.
-- Uses vim.ui.select, which is already backed by Snacks (see plugins/snacks.lua).
local M = {}

local function case_methods()
  local api = require("textcase").api
  local items = {}
  for _, method in pairs(api) do
    table.insert(items, method)
  end
  table.sort(items, function(a, b)
    return a.desc < b.desc
  end)
  return items
end

function M.select()
  local mode = vim.api.nvim_get_mode().mode
  local is_visual = mode == "v" or mode == "V" or mode == "\22"

  -- Mirrors what textcase's own `open_telescope` does: the visual region
  -- must be captured now, while still in visual mode, since opening the
  -- picker will exit it before the choice callback runs.
  if is_visual then
    local repeat_methods = require("strings.repeat.methods")
    local utils = require("textcase.shared.utils")
    repeat_methods.state.telescope_previous_mode = mode
    repeat_methods.state.telescope_previous_visual_region =
      utils.get_visual_region(0, true, nil, utils.get_mode_at_operator(mode))
  end

  vim.ui.select(case_methods(), {
    prompt = "Text Case",
    format_item = function(item)
      return item.desc
    end,
  }, function(choice)
    if not choice then
      return
    end
    local textcase = require("textcase")
    if is_visual then
      textcase.visual(choice.method_name)
    else
      textcase.current_word(choice.method_name)
    end
  end)
end

return M
