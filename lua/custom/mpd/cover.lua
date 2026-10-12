-- Cover art, fetched from MPD and cached on disk.
local client = require("custom.mpd.client")

local M = {}

M.dir = vim.fn.stdpath("cache") .. "/mpd-covers"

local covers = {} -- file -> path, or false when the song has no cover
local waiters = {} -- file -> callbacks waiting on an in-flight fetch

--- Resolves the cover of a song to a local image file, cached on disk.
--- Tries the embedded picture first, then a cover file in the song's directory.
---@param file string song uri
---@param cb fun(path?: string)
function M.get(file, cb)
  if covers[file] ~= nil then
    return cb(covers[file] or nil)
  end
  if waiters[file] then
    return table.insert(waiters[file], cb)
  end
  waiters[file] = { cb }

  local function done(path)
    covers[file] = path or false
    local cbs = waiters[file]
    waiters[file] = nil
    for _, waiter in ipairs(cbs) do
      waiter(path)
    end
  end

  local base = M.dir .. "/" .. vim.fn.sha256(file)
  for _, ext in ipairs({ "jpg", "png", "webp", "gif" }) do
    if vim.uv.fs_stat(base .. "." .. ext) then
      return done(base .. "." .. ext)
    end
  end

  local function fetch(cmd, fallback)
    local parts, mime, offset = {}, nil, 0
    local function chunk()
      client.request({ { "binarylimit", 1048576 }, { cmd, file, offset } }, function(res, bin)
        local size
        for _, kv in ipairs(res) do
          if kv[1] == "size" then
            size = tonumber(kv[2])
          elseif kv[1] == "type" then
            mime = kv[2]
          end
        end
        if not bin or not size then
          return fallback()
        end
        table.insert(parts, bin)
        offset = offset + #bin
        if #bin > 0 and offset < size then
          return chunk()
        end
        local data = table.concat(parts)
        local ext = mime and mime:match("^image/(%w+)") or (data:sub(1, 4) == "\137PNG" and "png" or "jpg")
        ext = ext == "jpeg" and "jpg" or ext
        vim.fn.mkdir(M.dir, "p")
        local path = base .. "." .. ext
        local f = io.open(path, "wb")
        if not f then
          return done()
        end
        f:write(data)
        f:close()
        done(path)
      end, fallback)
    end
    chunk()
  end

  fetch("readpicture", function()
    fetch("albumart", function()
      done()
    end)
  end)
end

return M
