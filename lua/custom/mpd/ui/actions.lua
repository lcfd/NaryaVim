-- Actions panel of the command center: every command, with its shortcut.
local commands = require("custom.mpd.ui.commands")
local panel = require("custom.mpd.ui.panel")

local M = {}

M.TITLE = "Actions"

--- The layout box the panel fills.
function M.box()
  return panel.box(M.TITLE, { height = #commands })
end

local function render(width)
  local rows = {}
  for _, cmd in ipairs(commands) do
    local label = " " .. cmd.icon .. "  " .. cmd.text
    local key = cmd.key and (cmd.key .. " ") or ""
    local pad = math.max(1, width - vim.fn.strdisplaywidth(label) - #key)
    table.insert(rows, {
      { " " .. cmd.icon .. "  ", "SnacksPickerIcon" },
      { cmd.text, "SnacksPickerCmd" },
      { string.rep(" ", pad) .. key, "Comment" },
    })
  end
  return rows
end

---@param h { run: fun(cmd: mpd.Command), keys: table<string, fun()>, on_focus: fun(focused: boolean) }
function M.new(h)
  local p
  local keys = vim.tbl_extend("force", {}, h.keys)
  keys["<CR>"] = function()
    h.run(commands[p.cursor()])
  end
  for _, cmd in ipairs(commands) do
    if cmd.key then
      keys[cmd.key] = function()
        h.run(cmd)
      end
    end
  end
  p = panel.new({ title = M.TITLE, render = render, keys = keys, on_focus = h.on_focus })
  return p
end

return M
