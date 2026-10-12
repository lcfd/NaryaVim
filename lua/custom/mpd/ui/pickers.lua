-- Pickers to add songs, albums and playlists to the queue, or songs and albums
-- to a playlist. They take over the screen, so they leave the open modal and
-- bring it back when done (or cancelled).
local client = require("custom.mpd.client")
local modal = require("custom.mpd.ui.modal")
local playlist = require("custom.mpd.playlist")
local song = require("custom.mpd.song")
local util = require("custom.mpd.util")

local M = {}

---@param on_confirm fun(item: table, done: fun())
---@param on_done fun() runs once the picker is finished: via `done`, or on cancel
local function pick(title, items, on_confirm, on_done)
  local confirmed = false
  Snacks.picker({
    title = title,
    items = items,
    format = "text",
    layout = { preset = "select" },
    confirm = function(picker, item)
      confirmed = item ~= nil
      picker:close()
      if item then
        on_confirm(item, on_done)
      end
    end,
    on_close = function()
      if not confirmed then
        vim.schedule(on_done)
      end
    end,
  })
end

--- Reports a failed request, then goes back to the modal.
local function failed(back)
  return function(err)
    util.notify(err, vim.log.levels.ERROR)
    back()
  end
end

--- Leaves the open modal, fetches `cmd` and picks one of the `items(res)`.
---@param add fun(item: table, done: fun())
local function choose(title, cmd, items, add)
  local back = modal.leave()
  client.request(cmd, function(res)
    pick(title, items(res), add, back)
  end, failed(back))
end

local function song_items(res)
  local items = {}
  for _, s in ipairs(song.parse(res)) do
    table.insert(items, { text = song.label(s), file = s.file })
  end
  table.sort(items, function(a, b)
    return a.text < b.text
  end)
  return items
end

local function album_items(res)
  return vim.tbl_map(function(album)
    return { text = album }
  end, song.values(res, "Album"))
end

--- Adds a song to the queue, or to the playlist `name`.
---@param name? string
function M.find_song(name)
  choose(name and ("MPD: Add Song to " .. name) or "MPD: Add Song", "listallinfo", song_items, function(item, done)
    if name then
      playlist.add(name, item.file, function()
        util.notify(("Added to %s: %s"):format(name, item.text))
        done()
      end)
    else
      client.send({ "add", item.file }, "Added: " .. item.text, done)
    end
  end)
end

--- Adds an album to the queue, or to the playlist `name`.
---@param name? string
function M.find_album(name)
  local title = name and ("MPD: Add Album to " .. name) or "MPD: Add Album"
  choose(title, { "list", "album" }, album_items, function(item, done)
    if name then
      playlist.add_album(name, item.text, function()
        util.notify(("Added album to %s: %s"):format(name, item.text))
        done()
      end)
    else
      client.send({ "findadd", "album", item.text }, "Added album: " .. item.text, done)
    end
  end)
end

--- Adds a playlist to the queue.
function M.find_playlist()
  local back = modal.leave()
  playlist.list(function(playlists)
    local items = vim.tbl_map(function(pl)
      return { text = pl.name }
    end, playlists)
    pick("MPD: Add Playlist", items, function(item, done)
      playlist.load(item.text, done)
    end, back)
  end, failed(back))
end

return M
