-- The playing song's title for the statusline, polled in the background.
local client = require("custom.mpd.client")
local song = require("custom.mpd.song")

local M = {}

local text, timer = "", nil

local function poll()
  local function set(new)
    if new ~= text then
      text = new
      pcall(function()
        require("lualine").refresh()
      end)
    end
  end
  client.request({ { "status" }, { "currentsong" } }, function(res)
    local state
    for _, kv in ipairs(res) do
      if kv[1] == "state" then
        state = kv[2]
      end
    end
    local s = song.parse(res)[1]
    if s and (state == "play" or state == "pause") then
      set((state == "play" and "󰝚 " or "󰏤 ") .. song.title(s))
    else
      set("")
    end
  end, function()
    set("") -- MPD not running: stay quiet
  end)
end

--- Title of the playing song, truncated to the room the statusline can spare.
--- Empty when nothing plays or the window is too narrow.
function M.get()
  if not timer then
    timer = assert(vim.uv.new_timer())
    timer:start(0, 2000, vim.schedule_wrap(poll))
  end
  local room = math.min(40, vim.o.columns - 130)
  if text == "" or room < 12 then
    return ""
  end
  if vim.fn.strdisplaywidth(text) > room then
    return vim.fn.strcharpart(text, 0, room - 1) .. "…"
  end
  return text
end

return M
