-- MPD client that doesn't depend on Telescope or mpc.
-- Speaks the MPD protocol directly over TCP (or a unix socket) via vim.uv,
-- and uses Snacks pickers for selection. Started as a port of paulfrische/mpd.nvim.
local M = {}

M.config = {
  -- A path starting with "/" is treated as a unix socket.
  host = vim.env.MPD_HOST or "127.0.0.1",
  port = tonumber(vim.env.MPD_PORT) or 6600,
}

function M.setup(opts)
  M.config = vim.tbl_extend("force", M.config, opts or {})
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "MPD" })
end

local function quote(arg)
  return '"' .. tostring(arg):gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
end

--- Builds a protocol line from a command and its arguments.
local function build(cmd)
  if type(cmd) == "string" then
    return cmd
  end
  local parts = { cmd[1] }
  for i = 2, #cmd do
    table.insert(parts, quote(cmd[i]))
  end
  return table.concat(parts, " ")
end

--- Sends one or more commands on a fresh connection.
--- On success `cb(pairs, binary)` is called on the main loop, where `pairs` is a
--- list of { key, value } and `binary` is the payload of a `binary:` response, if any.
---@param cmds string|table|table[] a command, or a list of commands (sent as a command list)
---@param cb? fun(pairs: table, binary?: string)
---@param on_error? fun(err: string) defaults to an error notification
function M.request(cmds, cb, on_error)
  if type(cmds) == "string" or type(cmds[1]) == "string" then
    cmds = { cmds }
  end
  local lines = vim.tbl_map(build, cmds)
  local payload = #lines == 1 and lines[1]
    or ("command_list_begin\n" .. table.concat(lines, "\n") .. "\ncommand_list_end")

  local host, port = M.config.host, M.config.port
  local is_unix = host:sub(1, 1) == "/"
  local handle = is_unix and vim.uv.new_pipe(false) or vim.uv.new_tcp()
  local buf, pos, greeted, done = "", 1, false, false
  local result, binary = {}, nil

  local function finish(err)
    if done then
      return
    end
    done = true
    if not handle:is_closing() then
      handle:close()
    end
    vim.schedule(function()
      if err then
        (on_error or function(e)
          notify(e, vim.log.levels.ERROR)
        end)(err)
      elseif cb then
        cb(result, binary)
      end
    end)
  end

  -- Consumes complete lines from `buf`; binary payloads are read by length.
  local function consume()
    while not done do
      local nl = buf:find("\n", pos, true)
      if not nl then
        return
      end
      local line = buf:sub(pos, nl - 1)
      if not greeted then
        if not line:match("^OK MPD ") then
          return finish("unexpected greeting: " .. line)
        end
        greeted = true
        pos = nl + 1
      elseif line == "OK" then
        return finish()
      elseif line:sub(1, 4) == "ACK " then
        return finish(line:sub(5))
      else
        local key, value = line:match("^([^:]+): (.*)$")
        if key == "binary" then
          local len = tonumber(value)
          -- payload is followed by a newline
          if #buf < nl + len + 1 then
            return
          end
          binary = buf:sub(nl + 1, nl + len)
          pos = nl + len + 2
        else
          if key then
            table.insert(result, { key, value })
          end
          pos = nl + 1
        end
      end
    end
  end

  local function on_connect(err)
    if err then
      return finish(("cannot connect to %s%s: %s"):format(host, is_unix and "" or (":" .. port), err))
    end
    handle:read_start(function(read_err, chunk)
      if read_err then
        return finish(read_err)
      end
      if not chunk then
        return finish("connection closed unexpectedly")
      end
      buf = buf .. chunk
      consume()
    end)
    handle:write(payload .. "\n")
  end

  if is_unix then
    handle:connect(host, on_connect)
  else
    vim.uv.getaddrinfo(host, nil, { socktype = "stream" }, function(err, res)
      if err or not res or not res[1] then
        return finish(("cannot resolve %s: %s"):format(host, err or "no address"))
      end
      handle:connect(res[1].addr, port, on_connect)
    end)
  end
end

--- Collects the values of a single key, e.g. the output of `list album`.
local function values(pairs_, key)
  local out, seen = {}, {}
  for _, kv in ipairs(pairs_) do
    if kv[1] == key and kv[2] ~= "" and not seen[kv[2]] then
      seen[kv[2]] = true
      table.insert(out, kv[2])
    end
  end
  return out
end

--- Groups key/value pairs into records, starting a new record at each `file` key.
local function songs(pairs_)
  local out, cur = {}, nil
  for _, kv in ipairs(pairs_) do
    local key, value = kv[1], kv[2]
    if key == "file" then
      cur = { file = value }
      table.insert(out, cur)
    elseif key == "directory" or key == "playlist" then
      cur = nil
    elseif cur and not cur[key] then
      cur[key] = value
    end
  end
  return out
end

local function song_title(s)
  return s.Title or s.Name or vim.fn.fnamemodify(s.file, ":t")
end

local function song_label(s)
  local label = s.Artist and (s.Artist .. " — " .. song_title(s)) or song_title(s)
  if s.Album then
    label = label .. "  (" .. s.Album .. ")"
  end
  return label
end

local function fmt_time(seconds)
  seconds = math.floor(tonumber(seconds) or 0)
  return ("%d:%02d"):format(math.floor(seconds / 60), seconds % 60)
end

--- Fetches status and queue in one round trip.
---@param cb fun(state: {status: table<string, string>, queue: table[], current?: table})
local function load_state(cb)
  M.request({ { "status" }, { "playlistinfo" } }, function(res)
    local status = {}
    for _, kv in ipairs(res) do
      if kv[1] == "file" then
        break
      end
      status[kv[1]] = kv[2]
    end
    local queue, current = songs(res), nil
    for _, s in ipairs(queue) do
      if s.Id == status.songid then
        current = s
      end
    end
    cb({ status = status, queue = queue, current = current })
  end)
end

--
-- Cover art
--

local covers = {} -- file -> path, or false when the song has no cover
local cover_waiters = {} -- file -> callbacks waiting on an in-flight fetch
local cover_dir = vim.fn.stdpath("cache") .. "/mpd-covers"

--- Resolves the cover of a song to a local image file, cached on disk.
--- Tries the embedded picture first, then a cover file in the song's directory.
---@param file string song uri
---@param cb fun(path?: string)
function M.cover(file, cb)
  if covers[file] ~= nil then
    return cb(covers[file] or nil)
  end
  if cover_waiters[file] then
    return table.insert(cover_waiters[file], cb)
  end
  cover_waiters[file] = { cb }

  local function done(path)
    covers[file] = path or false
    local waiters = cover_waiters[file]
    cover_waiters[file] = nil
    for _, waiter in ipairs(waiters) do
      waiter(path)
    end
  end

  local base = cover_dir .. "/" .. vim.fn.sha256(file)
  for _, ext in ipairs({ "jpg", "png", "webp", "gif" }) do
    if vim.uv.fs_stat(base .. "." .. ext) then
      return done(base .. "." .. ext)
    end
  end

  local function fetch(cmd, fallback)
    local parts, mime, offset = {}, nil, 0
    local function chunk()
      M.request({ { "binarylimit", 1048576 }, { cmd, file, offset } }, function(res, bin)
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
        vim.fn.mkdir(cover_dir, "p")
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

--
-- Playback
--

function M.play()
  M.request("play")
end

function M.pause()
  M.request({ "pause", "1" })
end

function M.toggle(cb)
  M.request("status", function(status)
    for _, kv in ipairs(status) do
      if kv[1] == "state" and kv[2] == "play" then
        return M.request({ "pause", "1" }, cb)
      end
    end
    M.request("play", cb)
  end)
end

function M.next(cb)
  M.request("next", cb)
end

function M.prev(cb)
  M.request("previous", cb)
end

--- Seeks relative to the current position, in seconds.
function M.seek(delta, cb)
  M.request({ "seekcur", (delta >= 0 and "+" or "") .. delta }, cb)
end

function M.shuffle(cb)
  M.request("shuffle", function()
    notify("Queue shuffled")
    if cb then
      cb()
    end
  end)
end

function M.clear(cb)
  M.request("clear", function()
    notify("Queue cleared")
    if cb then
      cb()
    end
  end)
end

function M.current()
  M.request("currentsong", function(res)
    local s = songs(res)[1]
    notify(s and ("Now playing: " .. song_label(s)) or "Nothing playing")
  end)
end

--
-- Pickers
--

local center -- the open command center picker, if any

--- Closes the command center if it's open, and returns a function that brings
--- it back. Pickers take over the screen (and Snacks auto-closes a picker that
--- loses focus), so sub-pickers leave the center and return to it when done.
local function leave_center()
  if center and not center.closed then
    center:close()
    center = nil
    return function()
      M.command_center()
    end
  end
  return function() end
end

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

function M.find_song()
  local back = leave_center()
  M.request("listallinfo", function(res)
    local items = {}
    for _, s in ipairs(songs(res)) do
      table.insert(items, { text = song_label(s), file = s.file })
    end
    table.sort(items, function(a, b)
      return a.text < b.text
    end)
    pick("MPD: Add Song", items, function(item, done)
      M.request({ "add", item.file }, function()
        notify("Added: " .. item.text)
        done()
      end)
    end, back)
  end)
end

function M.find_album()
  local back = leave_center()
  M.request({ "list", "album" }, function(res)
    local items = vim.tbl_map(function(album)
      return { text = album }
    end, values(res, "Album"))
    pick("MPD: Add Album", items, function(item, done)
      M.request({ "findadd", "album", item.text }, function()
        notify("Added album: " .. item.text)
        done()
      end)
    end, back)
  end)
end

--
-- Statusline: the playing song's title, polled in the background.
--

local statusline = { text = "", timer = nil }

local function poll_statusline()
  local function set(text)
    if text ~= statusline.text then
      statusline.text = text
      pcall(function()
        require("lualine").refresh()
      end)
    end
  end
  M.request({ { "status" }, { "currentsong" } }, function(res)
    local state
    for _, kv in ipairs(res) do
      if kv[1] == "state" then
        state = kv[2]
      end
    end
    local song = songs(res)[1]
    if song and (state == "play" or state == "pause") then
      set((state == "play" and "󰝚 " or "󰏤 ") .. song_title(song))
    else
      set("")
    end
  end, function()
    set("") -- MPD not running: stay quiet
  end)
end

--- Title of the playing song, truncated to the room the statusline can spare.
--- Empty when nothing plays or the window is too narrow.
function M.statusline()
  if not statusline.timer then
    statusline.timer = assert(vim.uv.new_timer())
    statusline.timer:start(0, 2000, vim.schedule_wrap(poll_statusline))
  end
  local room = math.min(40, vim.o.columns - 130)
  local text = statusline.text
  if text == "" or room < 12 then
    return ""
  end
  if vim.fn.strdisplaywidth(text) > room then
    return vim.fn.strcharpart(text, 0, room - 1) .. "…"
  end
  return text
end

--
-- Command center: commands + queue on the left, the selected song (or the
-- shortcuts, when on a command) on the right, and a "now playing" bar at the
-- bottom spanning the whole width.
--

-- Commands run while the picker stays open, then the view is refreshed.
-- `key` is a shortcut in the list (normal mode). Commands that `leave` hand
-- over to another picker, which returns to the center afterwards.
local commands = {
  { text = "Play / Pause", key = "p", icon = "󰐎", fn = M.toggle },
  { text = "Next", key = "n", icon = "󰒭", fn = M.next },
  { text = "Previous", key = "N", icon = "󰒮", fn = M.prev },
  {
    text = "Forward 10s",
    key = "l",
    icon = "󰵱",
    fn = function(cb)
      M.seek(10, cb)
    end,
  },
  {
    text = "Back 10s",
    key = "h",
    icon = "󰴪",
    fn = function(cb)
      M.seek(-10, cb)
    end,
  },
  { text = "Add Song", key = "s", icon = "󰐒", fn = M.find_song, leaves = true },
  { text = "Add Album", key = "a", icon = "󰀥", fn = M.find_album, leaves = true },
  { text = "Shuffle Queue", icon = "󰒝", fn = M.shuffle },
  { text = "Clear Queue", icon = "󰆴", fn = M.clear },
}

local BAR_HEIGHT = 12 -- rows inside the now playing bar's border
local COVER_WIDTH = 25 -- columns for the cover in the bar

local function build_items(state)
  local items = {}
  for _, cmd in ipairs(commands) do
    table.insert(items, vim.tbl_extend("force", { kind = "command" }, cmd))
  end
  if #state.queue > 0 then
    -- empty text: separators drop out as soon as you type a search
    table.insert(items, { kind = "separator", text = "" })
    table.insert(items, { kind = "separator", text = "", label = ("Queue · %d"):format(#state.queue) })
  end
  for _, s in ipairs(state.queue) do
    table.insert(items, {
      kind = "song",
      text = song_label(s),
      song = s,
      current = s == state.current,
    })
  end
  return items
end

local function format_item(item)
  if item.kind == "command" then
    return {
      { item.icon .. "  ", "SnacksPickerIcon" },
      { item.text, "SnacksPickerCmd" },
      item.key and { " (" .. item.key .. ")", "Comment" } or nil,
    }
  elseif item.kind == "separator" then
    if not item.label then
      return { { "" } }
    end
    return { { "── " .. item.label .. " " .. string.rep("─", 200), "Comment" } }
  end
  return {
    { item.current and "󰝚  " or "   ", "SnacksPickerSpecial" },
    { ("%3d  "):format(tonumber(item.song.Pos) + 1), "SnacksPickerIdx" },
    { item.text, item.current and "SnacksPickerSpecial" or nil },
  }
end

--- State icon, elapsed time, a bar sized to `width`, percentage and remaining time.
---@return string line, table[] highlights as { start_byte, end_byte, hl_group }
local function progress_line(status, width)
  local icon = ({ play = "󰐊", pause = "󰏤" })[status.state] or "󰓛"
  local elapsed, duration = tonumber(status.elapsed) or 0, tonumber(status.duration) or 0
  if duration <= 0 then
    -- streams have no duration
    return ("%s  %s"):format(icon, fmt_time(elapsed)), {}
  end
  local ratio = math.min(1, elapsed / duration)
  local left = ("%s  %s  "):format(icon, fmt_time(elapsed))
  local right = ("  %d%%  -%s"):format(math.floor(ratio * 100), fmt_time(duration - elapsed))
  local bar = math.max(10, width - vim.api.nvim_strwidth(left) - vim.api.nvim_strwidth(right))
  local filled = math.floor(ratio * bar + 0.5)
  local done, rest = string.rep("━", filled), string.rep("─", bar - filled)
  return left .. done .. rest .. right,
    {
      { #left, #left + #done, "Special" },
      { #left + #done, #left + #done + #rest, "Comment" },
    }
end

--- Writes lines given as lists of { text, hl_group? } chunks.
local function set_chunks(buf, ns, rows)
  local lines, marks = {}, {}
  for r, chunks in ipairs(rows) do
    local line = ""
    for _, chunk in ipairs(chunks) do
      if chunk[2] then
        table.insert(marks, { r - 1, #line, #line + #chunk[1], chunk[2] })
      end
      line = line .. chunk[1]
    end
    lines[r] = line
  end
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  for _, m in ipairs(marks) do
    vim.api.nvim_buf_set_extmark(buf, ns, m[1], m[2], { end_col = m[3], hl_group = m[4] })
  end
end

--- Snacks recognises Ghostty only from its reply to an XTVERSION query. When
--- that reply is missed, "unsupported" is cached for the whole session, so
--- fall back to the environment Ghostty sets.
local function images_supported()
  if Snacks.image.supports_terminal() then
    return true
  end
  local ghostty = vim.env.GHOSTTY_RESOURCES_DIR
    or vim.env.TERM_PROGRAM == "ghostty"
    or (vim.env.TERM or ""):find("ghostty")
  if ghostty and not vim.env.SNACKS_GHOSTTY then
    vim.env.SNACKS_GHOSTTY = "1"
    Snacks.image.terminal._env = nil -- recompute with the override
  end
  return Snacks.image.supports_terminal()
end

--
-- Now playing bar: a bordered float under the picker, with the cover in a
-- borderless float on top of its left edge.
--

local bar_ns = vim.api.nvim_create_namespace("custom.mpd.bar")

local function float_win(buf, cfg)
  local win = vim.api.nvim_open_win(buf, false, cfg)
  vim.wo[win].wrap = false
  vim.wo[win].winhighlight =
    "Normal:SnacksPicker,NormalFloat:SnacksPicker,FloatBorder:SnacksPickerBorder,FloatTitle:SnacksPickerTitle"
  return win
end

local function scratch()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  return buf
end

local function new_bar()
  local bar = {}

  local function geometry(picker)
    local root = picker.layout and picker.layout.root and picker.layout.root.win
    if not (root and vim.api.nvim_win_is_valid(root)) then
      return
    end
    local pos = vim.api.nvim_win_get_position(root)
    return {
      row = pos[1] + vim.api.nvim_win_get_height(root),
      col = pos[2],
      width = vim.api.nvim_win_get_width(root) - 2,
      zindex = (vim.api.nvim_win_get_config(root).zindex or 50) + 5,
    }
  end

  local function cover_cfg(g)
    return {
      relative = "editor",
      row = g.row + 1,
      col = g.col + 2,
      width = COVER_WIDTH,
      height = BAR_HEIGHT,
      style = "minimal",
      focusable = false,
      zindex = g.zindex + 1,
      noautocmd = true,
    }
  end

  function bar.open(picker)
    local g = geometry(picker)
    if not g then
      return
    end
    bar.buf = scratch()
    bar.win = float_win(bar.buf, {
      relative = "editor",
      row = g.row,
      col = g.col,
      width = g.width,
      height = BAR_HEIGHT,
      border = "rounded",
      title = " Now Playing ",
      style = "minimal",
      focusable = false,
      zindex = g.zindex,
      noautocmd = true,
    })
    bar.geometry = g
  end

  --- Follows the picker after a resize.
  function bar.reposition(picker)
    local g = geometry(picker)
    if not (g and bar.win and vim.api.nvim_win_is_valid(bar.win)) then
      return
    end
    bar.geometry = g
    vim.api.nvim_win_set_config(bar.win, { relative = "editor", row = g.row, col = g.col, width = g.width })
    if bar.cover_win and vim.api.nvim_win_is_valid(bar.cover_win) then
      vim.api.nvim_win_set_config(bar.cover_win, cover_cfg(g))
    end
  end

  local function close_cover()
    if bar.cover_win and vim.api.nvim_win_is_valid(bar.cover_win) then
      vim.api.nvim_win_close(bar.cover_win, true)
    end
    bar.cover_win, bar.cover_file = nil, nil
  end

  local function show_cover(file)
    if file == bar.cover_file then
      return
    end
    close_cover()
    bar.cover_file = file
    if not (file and images_supported()) then
      return
    end
    M.cover(file, function(path)
      if not path or bar.cover_file ~= file or not (bar.win and vim.api.nvim_win_is_valid(bar.win)) then
        return
      end
      -- Snacks loads each file as one terminal image, and Ghostty draws all of
      -- an image's placeholders with the size of its latest placement. Showing
      -- the same file in the right panel would resize (and crop) the bar's
      -- cover, so the bar uses its own copy.
      local bar_path = path:gsub("(%.%w+)$", ".bar%1")
      if not vim.uv.fs_stat(bar_path) and not vim.uv.fs_copyfile(path, bar_path) then
        return
      end
      local buf = scratch()
      bar.cover_win = float_win(buf, cover_cfg(bar.geometry))
      Snacks.image.buf.attach(buf, { src = bar_path })
    end)
  end

  function bar.render(state)
    if not (bar.buf and vim.api.nvim_buf_is_valid(bar.buf)) then
      return
    end
    local song, st = state.current, state.status
    show_cover(song and song.file)
    local indent = string.rep(" ", (song and images_supported()) and COVER_WIDTH + 4 or 2)
    if not song then
      return set_chunks(bar.buf, bar_ns, { {}, {}, { { indent .. "Nothing playing", "Comment" } } })
    end
    local subtitle = table.concat(
      vim.tbl_filter(function(s)
        return s ~= nil
      end, { song.Artist, song.Album, song.Date }),
      "  ·  "
    )
    local progress, hls = progress_line(st, bar.geometry.width - #indent - 2)
    local progress_chunks = { { indent } }
    local last = 0
    for _, hl in ipairs(hls) do
      table.insert(progress_chunks, { progress:sub(last + 1, hl[1]) })
      table.insert(progress_chunks, { progress:sub(hl[1] + 1, hl[2]), hl[3] })
      last = hl[2]
    end
    table.insert(progress_chunks, { progress:sub(last + 1) })
    local rows = {
      { { indent }, { song_title(song), "Title" } },
      { { indent }, { subtitle, "Comment" } },
      {},
      progress_chunks,
      {
        { indent },
        {
          ("Volume %s%%  ·  Random %s  ·  Repeat %s  ·  Track %d of %d"):format(
            st.volume or "?",
            st.random == "1" and "on" or "off",
            st["repeat"] == "1" and "on" or "off",
            tonumber(song.Pos) + 1,
            #state.queue
          ),
          "Comment",
        },
      },
    }
    -- center the rows vertically next to the cover
    for _ = 1, math.floor((BAR_HEIGHT - #rows) / 2) do
      table.insert(rows, 1, {})
    end
    set_chunks(bar.buf, bar_ns, rows)
  end

  function bar.close()
    close_cover()
    if bar.win and vim.api.nvim_win_is_valid(bar.win) then
      vim.api.nvim_win_close(bar.win, true)
    end
    bar.win = nil
  end

  return bar
end

--
-- Right panel
--

local COVER = { width = 30, height = 14 } -- max cells for the cover in the right panel
local details_ns = vim.api.nvim_create_namespace("custom.mpd.details")
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

--- Rows (as `set_chunks` chunks) for a song: centered title, then its fields.
local function song_details(song, is_current, width)
  local function centered(text, hl)
    local pad = math.max(0, math.floor((width - vim.fn.strdisplaywidth(text)) / 2))
    return { { string.rep(" ", pad) }, { text, hl } }
  end
  local rows = { centered(song_title(song), "Title") }
  if is_current then
    table.insert(rows, centered("󰝚 Now playing", "Special"))
  end
  table.insert(rows, {})
  local function field(label, value)
    table.insert(rows, { { "  " }, { ("%-14s"):format(label), "Comment" }, { value } })
  end
  for _, f in ipairs(FIELDS) do
    if song[f[1]] then
      field(f[2], song[f[1]])
    end
  end
  if song.duration then
    field("Duration", fmt_time(song.duration))
  end
  vim.list_extend(rows, { {}, { { "  " }, { song.file, "Comment" } } })
  return rows
end

local function shortcuts(state)
  local lines = { "# Shortcuts", "" }
  for _, cmd in ipairs(commands) do
    if cmd.key then
      table.insert(lines, ("- `%s`  %s"):format(cmd.key, cmd.text))
    end
  end
  local total = 0
  for _, s in ipairs(state.queue) do
    total = total + (tonumber(s.duration) or 0)
  end
  vim.list_extend(lines, {
    "- `d` / `<C-d>`  Remove song from queue",
    "- `<CR>`  Run command / play song",
    "- `i` or `/`  Search",
    "",
    ("**Queue**: %d tracks · %s"):format(#state.queue, fmt_time(total)),
  })
  return lines
end

function M.command_center()
  if center and not center.closed then
    return
  end
  local state ---@type {status: table, queue: table[], current?: table}
  local timer = assert(vim.uv.new_timer())
  local bar = new_bar()
  local last_cursor, resize_au

  local function preview(ctx)
    local item = ctx.item
    ctx.preview:reset()
    ctx.preview:minimal()
    Snacks.image.placement.clean(ctx.buf)

    if item.kind ~= "song" then
      ctx.preview:set_title("Shortcuts")
      ctx.preview:set_lines(shortcuts(state))
      return ctx.preview:highlight({ ft = "markdown" })
    end

    local song = item.song
    local is_current = state.current ~= nil and song.Id == state.current.Id
    ctx.preview:set_title("Queue #" .. (tonumber(song.Pos) + 1))

    -- The cover's rows are reserved up front and the image is drawn over them,
    -- so the text below never moves while covers load or change.
    local width = vim.api.nvim_win_get_width(ctx.win)
    local show_cover = images_supported()
    local rows = {}
    if show_cover then
      for i = 1, COVER.height + 1 do
        rows[i] = {}
      end
      -- placeholder in the middle of the cover area, hidden by the image
      local icon = "󰝚"
      rows[math.ceil(COVER.height / 2)] = { { string.rep(" ", math.floor(width / 2) - 1) }, { icon, "Comment" } }
    end
    vim.list_extend(rows, song_details(song, is_current, width))
    set_chunks(ctx.buf, details_ns, rows)

    if show_cover then
      local buf = ctx.buf
      M.cover(song.file, function(path)
        if not (path and ctx.preview.item == item and vim.api.nvim_buf_is_valid(buf)) then
          return
        end
        Snacks.image.placement.new(buf, path, {
          pos = { 1, 0 },
          range = { 1, 0, 1, 0 },
          inline = true,
          conceal = true, -- overlay the reserved rows instead of adding virtual lines
          max_width = COVER.width,
          max_height = COVER.height,
          -- once the image's size is known: center it, and cover exactly its rows
          on_update_pre = function(placement)
            local win = placement:wins()[1]
            if not win then
              return
            end
            local max = {
              width = math.min(COVER.width, vim.api.nvim_win_get_width(win)),
              height = math.min(COVER.height, vim.api.nvim_win_get_height(win)),
            }
            local size = Snacks.image.util.fit(placement.img.file, max, { info = placement.img.info })
            local col = math.max(0, math.floor((vim.api.nvim_win_get_width(win) - size.width) / 2))
            placement.opts.pos = { 1, col }
            placement.opts.range = { 1, col, size.height, col }
          end,
        })
      end)
    end
  end

  local picker
  local function refresh()
    load_state(function(new)
      if not picker or picker.closed then
        return
      end
      local changed = new.status.playlist ~= state.status.playlist
        or new.status.songid ~= state.status.songid
        or new.status.state ~= state.status.state
      state = new
      bar.render(state)
      if changed then
        -- new items re-trigger the preview on their own
        picker:refresh()
      end
    end)
  end

  local function run(cmd)
    if cmd.leaves then
      cmd.fn()
    else
      cmd.fn(refresh)
    end
  end

  local function remove(_, item)
    if item and item.kind == "song" then
      M.request({ "deleteid", item.song.Id }, refresh)
    end
  end

  -- shortcuts work in the list and in the search box's normal mode
  local actions = { mpd_remove = remove }
  local list_keys = {
    ["d"] = { "mpd_remove", desc = "Remove from queue" },
    ["<c-d>"] = { "mpd_remove", desc = "Remove from queue" },
  }
  local input_keys = {
    ["d"] = { "mpd_remove", mode = "n", desc = "Remove from queue" },
    ["<c-d>"] = { "mpd_remove", mode = { "n", "i" }, desc = "Remove from queue" },
  }
  for _, cmd in ipairs(commands) do
    if cmd.key then
      local name = "mpd_" .. cmd.key
      actions[name] = function()
        run(cmd)
      end
      list_keys[cmd.key] = { name, desc = cmd.text }
      input_keys[cmd.key] = { name, mode = "n", desc = cmd.text }
    end
  end

  load_state(function(initial)
    state = initial
    picker = Snacks.picker({
      title = "MPD Command Center",
      finder = function()
        return build_items(state)
      end,
      format = format_item,
      preview = preview,
      focus = "list",
      layout = {
        layout = {
          box = "horizontal",
          width = 0.8,
          min_width = 120,
          -- leave room below for the now playing bar
          height = function()
            return math.floor(vim.o.lines * 0.8) - (BAR_HEIGHT + 2)
          end,
          row = function()
            return math.floor(vim.o.lines * 0.1)
          end,
          {
            box = "vertical",
            border = true,
            title = "{title} {live} {flags}",
            { win = "input", height = 1, border = "bottom" },
            { win = "list", border = "none" },
          },
          { win = "preview", title = "{preview}", border = true, width = 0.5 },
        },
      },
      confirm = function(_, item)
        if not item or item.kind == "separator" then
          return
        end
        if item.kind == "song" then
          return M.request({ "playid", item.song.Id }, refresh)
        end
        run(item)
      end,
      -- step over separators in the direction the cursor was moving
      on_change = function(p, item)
        local cursor = p.list.cursor
        local dir = (last_cursor and cursor < last_cursor) and -1 or 1
        last_cursor = cursor
        if item and item.kind == "separator" then
          vim.schedule(function()
            if not p.closed then
              p.list:move(dir)
            end
          end)
        end
      end,
      on_show = function(p)
        vim.schedule(function()
          if p.closed then
            return
          end
          bar.open(p)
          bar.render(state)
          resize_au = vim.api.nvim_create_autocmd("VimResized", {
            callback = function()
              -- after Snacks has re-laid out the picker
              vim.schedule(function()
                bar.reposition(p)
                bar.render(state)
              end)
            end,
          })
        end)
      end,
      actions = actions,
      win = { input = { keys = input_keys }, list = { keys = list_keys } },
      on_close = function(p)
        center = nil
        timer:stop()
        timer:close()
        bar.close()
        if resize_au then
          pcall(vim.api.nvim_del_autocmd, resize_au)
        end
        if p.preview and p.preview.win and p.preview.win.buf then
          pcall(Snacks.image.placement.clean, p.preview.win.buf)
        end
      end,
    })
    center = picker
    timer:start(1000, 1000, vim.schedule_wrap(refresh))
  end)
end

return M
