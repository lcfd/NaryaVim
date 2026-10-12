-- Playlists: the stored playlists on the left, the selected playlist's songs
-- in the middle, and the details of what's focused (the playlist, or the song
-- under the cursor) on the right.
local client = require("custom.mpd.client")
local details = require("custom.mpd.ui.details")
local modal = require("custom.mpd.ui.modal")
local panel = require("custom.mpd.ui.panel")
local pickers = require("custom.mpd.ui.pickers")
local playlist = require("custom.mpd.playlist")
local song = require("custom.mpd.song")
local thumbs = require("custom.mpd.ui.thumbs")
local util = require("custom.mpd.util")

local M = {}

local SONGS_TITLE = "Songs"

--- Asks for a playlist name, refusing empty ones and the names in `taken`.
---@param taken table<string, boolean>
---@param cb fun(name: string)
local function ask_name(prompt, default, taken, cb)
  vim.ui.input({ prompt = prompt, default = default }, function(name)
    name = name and vim.trim(name) or ""
    if name == "" or name == default then
      return
    end
    if taken[name] then
      return util.notify("A playlist named " .. name .. " already exists", vim.log.levels.WARN)
    end
    cb(name)
  end)
end

local function confirm(msg)
  return vim.fn.confirm(msg, "&Yes\n&No", 2) == 1
end

---@param opts? { select?: string } name of the playlist to select
function M.open(opts)
  opts = opts or {}
  local picker ---@type snacks.Picker
  local songs_panel
  local playlists = {} ---@type mpd.Playlist[]
  local contents = {} ---@type table<string, mpd.Song[]> playlist -> songs, once loaded
  local loading = {} ---@type table<string, boolean>
  local select = opts.select -- playlist to select once the list is (re)drawn
  local shown -- playlist whose songs the songs panel shows
  local help = false -- details show the shortcuts
  local closing = false -- Snacks only marks the picker closed after `on_close`
  local resize_au

  local function alive()
    return picker ~= nil and not picker.closed and not closing
  end

  ---@return mpd.Playlist?
  local function current()
    local item = alive() and picker:current() or nil
    return item and item.playlist
  end

  local function taken()
    local names = {}
    for _, pl in ipairs(playlists) do
      names[pl.name] = true
    end
    return names
  end

  --
  -- Keys: { lhs, description, fn, panel } where panel is "songs" for the keys
  -- of the songs panel only; the others work in both panels.
  --

  local keys ---@type table[]

  local function help_lines()
    local lines = { "# Shortcuts", "" }
    for _, k in ipairs(keys) do
      table.insert(lines, ("- `%s`  %s%s"):format(k[1], k[2], k[4] == "songs" and " _(songs)_" or ""))
    end
    vim.list_extend(lines, {
      "- `<CR>`  Open the playlist's songs _(playlists)_",
      "- `i` or `/`  Search the playlists",
      "- `q` / `<Esc>`  Close",
    })
    return lines
  end

  --- Redraws the details of what's focused.
  local function show_details()
    if not alive() then
      return
    end
    if picker:current() then
      return picker.preview:show(picker, { force = true })
    end
    -- no playlist: Snacks won't call the preview
    details.reset(picker.preview)
    details.markdown(picker.preview, help_lines())
    picker:update_titles()
  end

  local function preview(ctx)
    details.reset(ctx.preview)
    if help then
      return details.markdown(ctx.preview, help_lines())
    end
    local pl = ctx.item.playlist
    local songs = contents[pl.name]
    local row = songs_panel.cursor()
    if songs_panel.focused() and songs and songs[row] then
      return details.song(ctx.preview, songs[row], { position = { "Position", row, #songs } })
    end
    details.playlist(ctx.preview, pl, songs)
  end

  --
  -- Songs panel
  --

  local function song_rows()
    local pl = current()
    if not pl then
      return { { { "  No playlists: press n to create one", "Comment" } } }
    end
    local songs = contents[pl.name]
    if not songs then
      return { { { "  Loading…", "Comment" } } }
    end
    if #songs == 0 then
      return { { { "  Empty: press a or A to add songs", "Comment" } } }
    end
    local rows, width = {}, #tostring(#songs)
    for i, s in ipairs(songs) do
      local row = { { " " } }
      local t = thumbs.get(s)
      if t then
        table.insert(row, t.hl and { thumbs.TEXT, t.hl } or { t.none and "󰎈 " or "  ", "Comment" })
        table.insert(row, { " " })
      end
      table.insert(row, { string.rep(" ", width - #tostring(i)) })
      table.insert(row, { tostring(i), "SnacksPickerIdx" })
      table.insert(row, { "  " })
      table.insert(row, { song.label(s) })
      rows[i] = row
    end
    return rows
  end

  --- Fetches the songs of a playlist (again, with `force`), then redraws.
  ---@param cursor? integer row to put the songs panel's cursor on
  local function load_songs(name, force, cursor)
    if (contents[name] and not force) or loading[name] then
      return
    end
    loading[name] = true
    playlist.songs(name, function(songs)
      loading[name] = nil
      contents[name] = songs
      local pl = current()
      if pl and pl.name == name then
        songs_panel.render()
        if cursor then
          songs_panel.set_cursor(cursor)
        end
        show_details()
      end
    end)
  end

  --- Re-fetches the playlists (their modification times change with every
  --- edit), selecting `name`.
  local function reload(name)
    playlist.list(function(list)
      if not alive() then
        return
      end
      playlists = list
      select = name
      picker.title = ("Playlists · %d"):format(#playlists)
      picker:refresh()
    end)
  end

  --- After an edit of the playlist `name`: re-fetch it and its songs.
  local function edited(name, cursor)
    return function()
      load_songs(name, true, cursor)
      reload(name)
    end
  end

  --
  -- Actions
  --

  local function with_playlist(fn)
    return function()
      local pl = current()
      if pl then
        fn(pl.name)
      end
    end
  end

  --- The song under the songs panel's cursor.
  local function with_song(fn)
    return function()
      local pl = current()
      local songs = pl and contents[pl.name]
      local row = songs_panel.cursor()
      if songs and songs[row] then
        fn(pl.name, songs, row)
      end
    end
  end

  local function new()
    ask_name("New playlist: ", nil, taken(), function(name)
      -- MPD creates a playlist with its first song
      util.notify("Pick the first song of " .. name)
      select = name
      pickers.find_song(name)
    end)
  end

  local function save_queue()
    ask_name("Save queue as: ", nil, taken(), function(name)
      playlist.save_queue(name, function()
        reload(name)
      end)
    end)
  end

  local function move(delta)
    return with_song(function(name, songs, row)
      local to = row + delta
      if to >= 1 and to <= #songs then
        playlist.move(name, row - 1, to - 1, edited(name, to))
      end
    end)
  end

  local function focus_playlists()
    picker:focus("list")
  end

  local function focus_songs()
    songs_panel.focus()
  end

  local function search()
    picker:focus("input")
    vim.cmd.startinsert()
  end

  keys = {
    { "n", "New playlist", new },
    { "S", "Save the queue as a playlist", save_queue },
    {
      "r",
      "Rename playlist",
      with_playlist(function(name)
        ask_name("Rename to: ", name, taken(), function(new_name)
          contents[new_name], contents[name] = contents[name], nil
          playlist.rename(name, new_name, function()
            reload(new_name)
          end)
        end)
      end),
    },
    {
      "D",
      "Delete playlist",
      with_playlist(function(name)
        if confirm("Delete playlist " .. name .. "?") then
          playlist.delete(name, function()
            contents[name] = nil
            reload()
          end)
        end
      end),
    },
    { "L", "Add playlist to the queue", with_playlist(playlist.load) },
    { "P", "Play playlist (replaces the queue)", with_playlist(playlist.play) },
    {
      "a",
      "Add a song to the playlist",
      with_playlist(function(name)
        select = name
        pickers.find_song(name)
      end),
    },
    {
      "A",
      "Add an album to the playlist",
      with_playlist(function(name)
        select = name
        pickers.find_album(name)
      end),
    },
    {
      "C",
      "Clear playlist",
      with_playlist(function(name)
        if confirm("Remove every song from " .. name .. "?") then
          playlist.clear(name, edited(name, 1))
        end
      end),
    },
    {
      "d",
      "Remove song from the playlist",
      with_song(function(name, _, row)
        playlist.remove(name, row - 1, edited(name, row))
      end),
      "songs",
    },
    { "K", "Move song up", move(-1), "songs" },
    { "J", "Move song down", move(1), "songs" },
    {
      "<CR>",
      "Add song to the queue",
      with_song(function(_, songs, row)
        client.send({ "add", songs[row].file }, "Added: " .. song.label(songs[row]))
      end),
      "songs",
    },
    { "1", "Focus playlists", focus_playlists },
    { "2", "Focus songs", focus_songs },
    {
      "?",
      "Toggle these shortcuts",
      function()
        help = not help
        show_details()
      end,
    },
  }

  -- picker keys: in the list, and in the search box's normal mode
  local picker_actions, list_keys, input_keys = {}, {}, {}
  -- songs panel keys
  local panel_keys = {
    ["q"] = function()
      picker:close()
    end,
    ["<Esc>"] = function()
      picker:close()
    end,
    ["i"] = search,
    ["/"] = search,
  }
  for i, k in ipairs(keys) do
    local lhs, desc, fn, only = k[1], k[2], k[3], k[4]
    panel_keys[lhs] = fn
    if only ~= "songs" then
      local name = "mpd_playlists_" .. i
      picker_actions[name] = fn
      list_keys[lhs] = { name, desc = desc }
      input_keys[lhs] = { name, mode = "n", desc = desc }
    end
  end

  songs_panel = panel.new({
    title = SONGS_TITLE,
    render = song_rows,
    keys = panel_keys,
    -- on WinLeave the panel is still the current window
    on_focus = function()
      vim.schedule(show_details)
    end,
    on_cursor = show_details,
  })

  playlist.list(function(list)
    playlists = list
    picker = Snacks.picker({
      title = ("Playlists · %d"):format(#playlists),
      finder = function()
        return vim.tbl_map(function(pl)
          return { text = pl.name, playlist = pl }
        end, playlists)
      end,
      format = function(item)
        return { { "󰲸  ", "SnacksPickerIcon" }, { item.playlist.name } }
      end,
      preview = preview,
      focus = "list",
      show_empty = true, -- there's always "new playlist"
      layout = {
        layout = {
          box = "horizontal",
          width = 0.85,
          min_width = 120,
          height = 0.8,
          {
            box = "vertical",
            border = true,
            width = 0.25,
            title = "{title} {live} {flags}",
            { win = "input", height = 1, border = "bottom" },
            { win = "list", border = "none" },
          },
          panel.box(SONGS_TITLE),
          { win = "preview", title = "{preview}", border = true, width = 0.35 },
        },
      },
      on_change = function(p, item)
        -- after a (re)load, move to the playlist to select
        if select then
          local name = select
          select = nil
          for i, it in ipairs(p.list.items) do
            if it.playlist.name == name and it ~= item then
              return p.list:view(i)
            end
          end
        end
        local pl = item and item.playlist
        if (pl and pl.name) ~= shown then
          shown = pl and pl.name
          songs_panel.render()
          songs_panel.set_cursor(1)
        end
        if pl then
          load_songs(pl.name)
        else
          vim.schedule(show_details)
        end
      end,
      confirm = focus_songs,
      on_show = function(p)
        vim.schedule(function()
          if p.closed then
            return
          end
          songs_panel.open(p)
          resize_au = vim.api.nvim_create_autocmd("VimResized", {
            callback = function()
              -- after Snacks has re-laid out the picker
              vim.schedule(function()
                songs_panel.reposition(p)
              end)
            end,
          })
        end)
      end,
      actions = picker_actions,
      win = { input = { keys = input_keys }, list = { keys = list_keys } },
      on_close = function(p)
        closing = true
        modal.clear(p)
        if thumbs.on_update == songs_panel.render then
          thumbs.on_update = nil
        end
        songs_panel.close()
        if resize_au then
          pcall(vim.api.nvim_del_autocmd, resize_au)
        end
        if p.preview and p.preview.win and p.preview.win.buf then
          pcall(Snacks.image.placement.clean, p.preview.win.buf)
        end
      end,
    })
    modal.set({
      picker = picker,
      -- back on the same playlist (or the one a picker is adding to)
      reopen = function()
        M.open({ select = select or shown })
      end,
    })
    thumbs.on_update = songs_panel.render
  end)
end

return M
