-- MPD client that doesn't depend on Telescope or mpc.
-- Speaks the MPD protocol directly over TCP (or a unix socket) via vim.uv,
-- and uses Snacks pickers for selection. Started as a port of paulfrische/mpd.nvim.
--
-- This module is the public API; see README.md. The UI modules (`ui/*`) need
-- Snacks, so they're only loaded when used: the statusline loads at startup.
local player = require("custom.mpd.player")

local M = {}

M.setup = require("custom.mpd.config").setup
M.request = require("custom.mpd.client").request
M.cover = require("custom.mpd.cover").get
M.statusline = require("custom.mpd.statusline").get
M.playlist = require("custom.mpd.playlist")

M.play = player.play
M.pause = player.pause
M.toggle = player.toggle
M.next = player.next
M.prev = player.prev
M.seek = player.seek
M.shuffle = player.shuffle
M.clear = player.clear
M.toggle_random = player.toggle_random
M.toggle_repeat = player.toggle_repeat
M.toggle_repeat_song = player.toggle_repeat_song
M.update_library = player.update_library
M.rescan_library = player.rescan_library
M.current = player.current

function M.command_center()
  require("custom.mpd.ui.center").open()
end

function M.playlists()
  require("custom.mpd.ui.playlists").open()
end

--- Adds a song to the queue, or to the playlist `name`.
---@param name? string
function M.find_song(name)
  require("custom.mpd.ui.pickers").find_song(name)
end

--- Adds an album to the queue, or to the playlist `name`.
---@param name? string
function M.find_album(name)
  require("custom.mpd.ui.pickers").find_album(name)
end

--- Adds a playlist to the queue.
function M.find_playlist()
  require("custom.mpd.ui.pickers").find_playlist()
end

return M
