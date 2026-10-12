-- Stored playlists.
local client = require("custom.mpd.client")
local song = require("custom.mpd.song")

local M = {}

local send = client.send

---@class mpd.Playlist
---@field name string
---@field modified? string last modification, ISO 8601 in UTC

--- All stored playlists, sorted by name.
---@param cb fun(playlists: mpd.Playlist[])
---@param on_error? fun(err: string)
function M.list(cb, on_error)
  client.request("listplaylists", function(res)
    local out, cur = {}, nil
    for _, kv in ipairs(res) do
      if kv[1] == "playlist" then
        cur = { name = kv[2] }
        table.insert(out, cur)
      elseif kv[1] == "Last-Modified" and cur then
        cur.modified = kv[2]
      end
    end
    table.sort(out, function(a, b)
      return a.name:lower() < b.name:lower()
    end)
    cb(out)
  end, on_error)
end

---@param cb fun(songs: mpd.Song[])
function M.songs(name, cb)
  client.request({ "listplaylistinfo", name }, function(res)
    cb(song.parse(res))
  end)
end

--- Appends the playlist to the queue.
function M.load(name, cb)
  send({ "load", name }, "Added playlist: " .. name, cb)
end

--- Replaces the queue with the playlist and plays it.
function M.play(name, cb)
  send({ { "clear" }, { "load", name }, { "play" } }, "Playing playlist: " .. name, cb)
end

--- Saves the queue as a new playlist.
function M.save_queue(name, cb)
  send({ "save", name }, "Saved queue as: " .. name, cb)
end

--- Adds a song, creating the playlist if it doesn't exist.
function M.add(name, file, cb)
  send({ "playlistadd", name, file }, nil, cb)
end

--- Adds every song of an album, creating the playlist if it doesn't exist.
function M.add_album(name, album, cb)
  local filter = ('(album == "%s")'):format(album:gsub('[\\"]', "\\%0"))
  send({ "searchaddpl", name, filter }, nil, cb)
end

--- Removes the song at `pos` (0-based).
function M.remove(name, pos, cb)
  send({ "playlistdelete", name, pos }, nil, cb)
end

--- Moves the song at `from` to `to` (0-based).
function M.move(name, from, to, cb)
  send({ "playlistmove", name, from, to }, nil, cb)
end

function M.clear(name, cb)
  send({ "playlistclear", name }, "Cleared playlist: " .. name, cb)
end

function M.rename(name, new_name, cb)
  send({ "rename", name, new_name }, ("Renamed %s to %s"):format(name, new_name), cb)
end

function M.delete(name, cb)
  send({ "rm", name }, "Deleted playlist: " .. name, cb)
end

return M
