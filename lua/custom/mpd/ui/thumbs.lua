-- Queue thumbnails: a 2x1 cell cover in front of each song, drawn with kitty
-- unicode placeholders. Songs of the same album share one thumbnail.
local cover = require("custom.mpd.cover")
local ui = require("custom.mpd.ui.util")

local M = {}

---@class mpd.Thumb
---@field hl? string highlight group drawing the image, once it's loaded
---@field none? boolean the song has no cover

--- Called (debounced) whenever a thumbnail finishes loading.
---@type fun()?
M.on_update = nil

--- The text drawing a thumbnail, with `hl` as its highlight group: each cell is
--- the placeholder + diacritics encoding its row and column.
M.TEXT = (function()
  local placeholder, d = vim.fn.nr2char(0x10EEEE), vim.fn.nr2char
  return placeholder .. d(0x0305) .. d(0x0305) .. placeholder .. d(0x0305) .. d(0x030D)
end)()

local thumbs = {} ---@type table<string, mpd.Thumb> album (or file) -> thumbnail

--- Batches the updates of thumbnails that load together.
local pending = false
local function updated()
  if pending then
    return
  end
  pending = true
  vim.defer_fn(function()
    pending = false
    if M.on_update then
      M.on_update()
    end
  end, 50)
end

--- Shows the thumbnail image `path` as a 2x1 virtual placement, and stores the
--- highlight group that draws it in `t`.
---@param t mpd.Thumb
local function place(t, path)
  Snacks.image.setup()
  local img = Snacks.image.image.new(path)
  local sent = img.sent
  -- Snacks calls `update` on an image's placements once its data is sent to
  -- the terminal, but not for an image that was sent already.
  local placement = {
    update = function(self)
      Snacks.image.terminal.request({ a = "p", U = 1, i = img.id, p = self.id, C = 1, c = 2, r = 1 })
      t.hl = "MpdThumb" .. img.id
      -- the image id is encoded in the foreground, the placement in the underline
      Snacks.util.set_hl({ [t.hl] = { fg = img.id, sp = self.id, bg = "none", nocombine = true } })
      updated()
    end,
    error = function()
      t.none = true
      updated()
    end,
  }
  img:place(placement)
  if sent then
    placement:update()
  end
end

--- Thumbnail of a song, fetched in the background on first use.
---@param song mpd.Song
---@return mpd.Thumb? nil when the terminal can't show it
function M.get(song)
  if not (ui.images_supported() and Snacks.image.terminal.env().placeholders) then
    return
  end
  local key = song.Album and ((song.AlbumArtist or song.Artist or "") .. "\0" .. song.Album) or song.file
  if thumbs[key] then
    return thumbs[key]
  end
  local t = {}
  thumbs[key] = t
  cover.get(song.file, function(path)
    if not path then
      t.none = true
      return updated()
    end
    -- its own (small) file: Ghostty draws every placement of an image with the
    -- size of the latest one, see the now playing bar
    local thumb_path = path:gsub("%.%w+$", ".thumb.png")
    if vim.uv.fs_stat(thumb_path) then
      return place(t, thumb_path)
    end
    local magick = vim.fn.executable("magick") == 1 and "magick" or vim.fn.executable("convert") == 1 and "convert"
    if not magick then
      return place(t, path)
    end
    vim.system({ magick, path .. "[0]", "-thumbnail", "64x64", thumb_path }, {}, function(res)
      vim.schedule(function()
        place(t, res.code == 0 and thumb_path or path)
      end)
    end)
  end)
  return t
end

return M
