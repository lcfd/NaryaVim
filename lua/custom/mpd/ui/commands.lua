-- The command center's actions. They run while the center stays open, then
-- the view is refreshed. `key` is a shortcut in every panel (normal mode).
-- Commands that `leave` hand over to another picker, which returns to the
-- center afterwards.
local pickers = require("custom.mpd.ui.pickers")
local player = require("custom.mpd.player")

---@class mpd.Command
---@field text string
---@field key? string
---@field icon string
---@field fn fun(cb?: fun())
---@field leaves? boolean

---@type mpd.Command[]
return {
  { text = "Play / Pause", key = "p", icon = "󰐎", fn = player.toggle },
  { text = "Next", key = "n", icon = "󰒭", fn = player.next },
  { text = "Previous", key = "N", icon = "󰒮", fn = player.prev },
  {
    text = "Forward 10s",
    key = "l",
    icon = "󰵱",
    fn = function(cb)
      player.seek(10, cb)
    end,
  },
  {
    text = "Back 10s",
    key = "h",
    icon = "󰴪",
    fn = function(cb)
      player.seek(-10, cb)
    end,
  },
  { text = "Random", key = "r", icon = "󰒟", fn = player.toggle_random },
  { text = "Repeat Queue", key = "R", icon = "󰑖", fn = player.toggle_repeat },
  { text = "Repeat Song", key = "o", icon = "󰑘", fn = player.toggle_repeat_song },
  { text = "Add Song", key = "s", icon = "󰐒", fn = pickers.find_song, leaves = true },
  { text = "Add Album", key = "a", icon = "󰀥", fn = pickers.find_album, leaves = true },
  { text = "Add Playlist", key = "P", icon = "󰲸", fn = pickers.find_playlist, leaves = true },
  { text = "Shuffle Queue", key = "S", icon = "󰒝", fn = player.shuffle },
  { text = "Clear Queue", key = "C", icon = "󰆴", fn = player.clear },
  { text = "Update Library", key = "u", icon = "󰑓", fn = player.update_library },
  { text = "Rescan Library", key = "U", icon = "󰑐", fn = player.rescan_library },
}
