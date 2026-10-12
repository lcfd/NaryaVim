-- Details panel (a picker's preview): the cover and tags of a song or a
-- playlist, or markdown such as the shortcuts.
local cover = require("custom.mpd.cover")
local song = require("custom.mpd.song")
local ui = require("custom.mpd.ui.util")
local util = require("custom.mpd.util")

local M = {}

M.TITLE = "Details"

local COVER = { width = 30, height = 14 } -- max cells for the cover
local ns = vim.api.nvim_create_namespace("custom.mpd.details")
local FIELDS = {
  { "Artist", "Artist" },
  { "Album", "Album" },
  { "AlbumArtist", "Album artist" },
  { "Date", "Date" },
  { "Genre", "Genre" },
  { "Track", "Track" },
  { "Disc", "Disc" },
  { "Composer", "Composer" },
}

local tokens = {} -- buf -> token of its latest render: covers loading for an older one are dropped

--- Builds rows (as `set_chunks` chunks) for a panel `width` wide: centered
--- lines, then `label  value` fields.
local function rows_builder(width)
  local rows = {}
  local b = { rows = rows }
  function b.centered(text, hl)
    local pad = math.max(0, math.floor((width - vim.fn.strdisplaywidth(text)) / 2))
    table.insert(rows, { { string.rep(" ", pad) }, { text, hl } })
  end
  function b.field(label, value)
    table.insert(rows, { { "  " }, { ("%-14s"):format(label), "Comment" }, { value } })
  end
  function b.line(text, hl)
    table.insert(rows, { { "  " }, { text, hl } })
  end
  function b.blank()
    table.insert(rows, {})
  end
  return b
end

--- Renders the rows built by `build(width)` under the cover of `file` (when
--- there's room for it). The cover's rows are reserved up front and the image
--- is drawn over them, so the text never moves while covers load or change.
---@param build fun(b: table)
---@param file? string song whose cover to show
local function render(preview, build, file)
  local buf, win = preview.win.buf, preview.win.win
  local token = {}
  tokens[buf] = token
  preview:set_title(M.TITLE)

  local width = vim.api.nvim_win_get_width(win)
  local b = rows_builder(width)
  build(b)
  local cover_height = math.min(COVER.height, vim.api.nvim_win_get_height(win) - #b.rows - 1)
  local show_cover = file ~= nil and cover_height >= 4 and ui.images_supported()
  local rows = {}
  if show_cover then
    for i = 1, cover_height + 1 do
      rows[i] = {}
    end
    -- placeholder in the middle of the cover area, hidden by the image
    rows[math.ceil(cover_height / 2)] = { { string.rep(" ", math.floor(width / 2) - 1) }, { "󰝚", "Comment" } }
  end
  vim.list_extend(rows, b.rows)
  ui.set_chunks(buf, ns, rows)

  if not show_cover then
    return
  end
  cover.get(file, function(path)
    if not (path and tokens[buf] == token and vim.api.nvim_buf_is_valid(buf)) then
      return
    end
    Snacks.image.placement.new(buf, path, {
      pos = { 1, 0 },
      range = { 1, 0, 1, 0 },
      inline = true,
      conceal = true, -- overlay the reserved rows instead of adding virtual lines
      max_width = COVER.width,
      max_height = cover_height,
      -- once the image's size is known: center it, and cover exactly its rows
      on_update_pre = function(placement)
        local w = placement:wins()[1]
        if not w then
          return
        end
        local max = {
          width = math.min(COVER.width, vim.api.nvim_win_get_width(w)),
          height = math.min(cover_height, vim.api.nvim_win_get_height(w)),
        }
        local size = Snacks.image.util.fit(placement.img.file, max, { info = placement.img.info })
        local col = math.max(0, math.floor((vim.api.nvim_win_get_width(w) - size.width) / 2))
        placement.opts.pos = { 1, col }
        placement.opts.range = { 1, col, size.height, col }
      end,
    })
  end)
end

--- Clears what a previous render left in the preview.
function M.reset(preview)
  tokens[preview.win.buf] = nil
  preview:reset()
  preview:minimal()
  preview:wo({ fillchars = "eob: " }) -- no `~` under short content
  Snacks.image.placement.clean(preview.win.buf)
end

---@param lines string[]
function M.markdown(preview, lines)
  preview:set_title(M.TITLE)
  preview:set_lines(lines)
  preview:highlight({ ft = "markdown" })
end

--- A song: centered title, its fields, its file, and last its position.
---@param s mpd.Song
---@param opts? { current?: boolean, position?: { [1]: string, [2]: integer, [3]: integer } label, n, total
function M.song(preview, s, opts)
  opts = opts or {}
  render(preview, function(b)
    b.centered(song.title(s), "Title")
    if opts.current then
      b.centered("󰝚 Now playing", "Special")
    end
    b.blank()
    for _, f in ipairs(FIELDS) do
      if s[f[1]] then
        b.field(f[2], s[f[1]])
      end
    end
    if s.duration then
      b.field("Duration", util.fmt_time(s.duration))
    end
    b.blank()
    b.line(s.file, "Comment")
    if opts.position then
      local p = opts.position
      b.blank()
      b.field(p[1], ("%d of %d"):format(p[2], p[3]))
    end
  end, s.file)
end

--- A playlist: its name, size and length, main artists, and when it changed.
--- Shows the cover of its first song.
---@param pl mpd.Playlist
---@param songs? mpd.Song[] nil while loading
function M.playlist(preview, pl, songs)
  render(preview, function(b)
    b.centered(pl.name, "Title")
    b.centered("󰲸 Playlist", "Comment")
    b.blank()
    if not songs then
      b.field("Songs", "loading…")
    else
      local total, artists, order = 0, {}, {}
      for _, s in ipairs(songs) do
        total = total + (tonumber(s.duration) or 0)
        local artist = s.AlbumArtist or s.Artist
        if artist then
          if not artists[artist] then
            table.insert(order, artist)
          end
          artists[artist] = (artists[artist] or 0) + 1
        end
      end
      -- most frequent first, ties in playlist order
      local rank = {}
      for i, a in ipairs(order) do
        rank[a] = i
      end
      table.sort(order, function(a, b2)
        if artists[a] ~= artists[b2] then
          return artists[a] > artists[b2]
        end
        return rank[a] < rank[b2]
      end)
      b.field("Songs", tostring(#songs))
      b.field("Duration", util.fmt_time(total))
      if #order > 0 then
        local top = vim.list_slice(order, 1, 3)
        b.field("Artists", table.concat(top, ", ") .. (#order > 3 and (" +" .. (#order - 3)) or ""))
      end
    end
    if pl.modified then
      b.field("Modified", util.fmt_date(pl.modified))
    end
  end, songs and songs[1] and songs[1].file or nil)
end

return M
