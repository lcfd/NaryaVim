-- The queue panel's items and how they're drawn.
local song = require("custom.mpd.song")
local thumbs = require("custom.mpd.ui.thumbs")

local M = {}

---@param state mpd.State
function M.items(state)
  local items = {}
  local width = #tostring(#state.queue)
  for _, s in ipairs(state.queue) do
    table.insert(items, {
      text = song.label(s),
      song = s,
      current = s == state.current,
      width = width,
    })
  end
  return items
end

function M.format(item)
  local ret = {}
  local t = thumbs.get(item.song)
  if t then
    if t.hl then
      table.insert(ret, { thumbs.TEXT, t.hl, inline = true })
    else
      table.insert(ret, { t.none and "󰎈 " or "  ", "Comment" })
    end
    table.insert(ret, { " " })
  end
  local idx = item.current and "󰝚" or tostring(tonumber(item.song.Pos) + 1)
  table.insert(ret, { string.rep(" ", item.width - vim.fn.strdisplaywidth(idx)) })
  table.insert(ret, { idx, item.current and "SnacksPickerSpecial" or "SnacksPickerIdx" })
  table.insert(ret, { "  " })
  table.insert(ret, { item.text, item.current and "SnacksPickerSpecial" or nil })
  return ret
end

function M.title(state)
  return ("Queue · %d"):format(#state.queue)
end

return M
