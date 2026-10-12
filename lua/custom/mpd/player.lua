-- Playback, queue and library commands.
local client = require("custom.mpd.client")
local song = require("custom.mpd.song")
local util = require("custom.mpd.util")

local M = {}

local request, send, notify = client.request, client.send, util.notify

---@class mpd.State
---@field status table<string, string>
---@field queue mpd.Song[]
---@field current? mpd.Song

--- Fetches status and queue in one round trip.
---@param cb fun(state: mpd.State)
function M.state(cb)
  request({ { "status" }, { "playlistinfo" } }, function(res)
    local status = {}
    for _, kv in ipairs(res) do
      if kv[1] == "file" then
        break
      end
      status[kv[1]] = kv[2]
    end
    local queue, current = song.parse(res), nil
    for _, s in ipairs(queue) do
      if s.Id == status.songid then
        current = s
      end
    end
    cb({ status = status, queue = queue, current = current })
  end)
end

function M.play()
  request("play")
end

function M.pause()
  request({ "pause", "1" })
end

function M.toggle(cb)
  request("status", function(status)
    for _, kv in ipairs(status) do
      if kv[1] == "state" and kv[2] == "play" then
        return request({ "pause", "1" }, cb)
      end
    end
    request("play", cb)
  end)
end

function M.next(cb)
  request("next", cb)
end

function M.prev(cb)
  request("previous", cb)
end

--- Seeks relative to the current position, in seconds.
function M.seek(delta, cb)
  request({ "seekcur", (delta >= 0 and "+" or "") .. delta }, cb)
end

function M.shuffle(cb)
  send("shuffle", "Queue shuffled", cb)
end

function M.clear(cb)
  send("clear", "Queue cleared", cb)
end

--- Calls `cb(status)` with the server status as a key -> value table.
local function with_status(cb)
  request("status", function(res)
    local status = {}
    for _, kv in ipairs(res) do
      status[kv[1]] = kv[2]
    end
    cb(status)
  end)
end

function M.toggle_random(cb)
  with_status(function(st)
    local on = st.random == "1"
    send({ "random", on and "0" or "1" }, on and "Random off" or "Random on", cb)
  end)
end

--- Repeat modes are MPD's `repeat` + `single` flags: repeat alone loops the
--- queue, repeat with single loops the current song.
function M.toggle_repeat(cb)
  with_status(function(st)
    if st["repeat"] == "1" and st.single ~= "1" then
      send({ "repeat", "0" }, "Repeat queue off", cb)
    else
      send({ { "repeat", "1" }, { "single", "0" } }, "Repeat queue on", cb)
    end
  end)
end

function M.toggle_repeat_song(cb)
  with_status(function(st)
    if st["repeat"] == "1" and st.single == "1" then
      send({ { "repeat", "0" }, { "single", "0" } }, "Repeat song off", cb)
    else
      send({ { "repeat", "1" }, { "single", "1" } }, "Repeat song on", cb)
    end
  end)
end

--- Starts a database update, then notifies again once MPD is done with it.
local function update_db(cmd, msg, cb)
  request(cmd, function()
    notify(msg .. " started")
    if cb then
      cb()
    end
    local timer, done = assert(vim.uv.new_timer()), false
    local function stop(text, level)
      if done then
        return
      end
      done = true
      timer:stop()
      timer:close()
      notify(text, level)
    end
    timer:start(
      1000,
      1000,
      vim.schedule_wrap(function()
        request("status", function(res)
          for _, kv in ipairs(res) do
            if kv[1] == "updating_db" then
              return
            end
          end
          stop(msg .. " finished")
        end, function(err)
          stop(msg .. " failed: " .. err, vim.log.levels.ERROR)
        end)
      end)
    )
  end)
end

--- Scans the music directory for new, changed and removed files.
function M.update_library(cb)
  update_db("update", "Library update", cb)
end

--- Like `update_library`, but re-reads every file, even unchanged ones.
function M.rescan_library(cb)
  update_db("rescan", "Library rescan", cb)
end

function M.current()
  request("currentsong", function(res)
    local s = song.parse(res)[1]
    notify(s and ("Now playing: " .. song.label(s)) or "Nothing playing")
  end)
end

return M
