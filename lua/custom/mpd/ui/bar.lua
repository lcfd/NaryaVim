-- Now playing bar: a bordered float under the picker, with the cover in a
-- borderless float on top of its left edge.
local cover = require("custom.mpd.cover")
local song = require("custom.mpd.song")
local ui = require("custom.mpd.ui.util")
local util = require("custom.mpd.util")

local M = {}

M.HEIGHT = 12 -- rows inside the border
local COVER_WIDTH = 25 -- columns for the cover

local ns = vim.api.nvim_create_namespace("custom.mpd.bar")

--- State icon, elapsed time, a bar sized to `width`, percentage and remaining time.
---@return string line, table[] highlights as { start_byte, end_byte, hl_group }
local function progress_line(status, width)
  local icon = ({ play = "󰐊", pause = "󰏤" })[status.state] or "󰓛"
  local elapsed, duration = tonumber(status.elapsed) or 0, tonumber(status.duration) or 0
  if duration <= 0 then
    -- streams have no duration
    return ("%s  %s"):format(icon, util.fmt_time(elapsed)), {}
  end
  local ratio = math.min(1, elapsed / duration)
  local left = ("%s  %s  "):format(icon, util.fmt_time(elapsed))
  local right = ("  %d%%  -%s"):format(math.floor(ratio * 100), util.fmt_time(duration - elapsed))
  local bar = math.max(10, width - vim.api.nvim_strwidth(left) - vim.api.nvim_strwidth(right))
  local filled = math.floor(ratio * bar + 0.5)
  local done, rest = string.rep("━", filled), string.rep("─", bar - filled)
  return left .. done .. rest .. right,
    {
      { #left, #left + #done, "Special" },
      { #left + #done, #left + #done + #rest, "Comment" },
    }
end

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
    height = M.HEIGHT,
    style = "minimal",
    focusable = false,
    zindex = g.zindex + 1,
    noautocmd = true,
  }
end

function M.new()
  local bar = {}

  function bar.open(picker)
    local g = geometry(picker)
    if not g then
      return
    end
    bar.buf = ui.scratch()
    bar.win = ui.float_win(bar.buf, {
      relative = "editor",
      row = g.row,
      col = g.col,
      width = g.width,
      height = M.HEIGHT,
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
    if not (file and ui.images_supported()) then
      return
    end
    cover.get(file, function(path)
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
      local buf = ui.scratch()
      bar.cover_win = ui.float_win(buf, cover_cfg(bar.geometry))
      Snacks.image.buf.attach(buf, { src = bar_path })
    end)
  end

  ---@param state mpd.State
  function bar.render(state)
    if not (bar.buf and vim.api.nvim_buf_is_valid(bar.buf)) then
      return
    end
    local s, st = state.current, state.status
    show_cover(s and s.file)
    local indent = string.rep(" ", (s and ui.images_supported()) and COVER_WIDTH + 4 or 2)
    if not s then
      return ui.set_chunks(bar.buf, ns, { {}, {}, { { indent .. "Nothing playing", "Comment" } } })
    end
    local subtitle = table.concat(
      vim.tbl_filter(function(v)
        return v ~= nil
      end, { s.Artist, s.Album, s.Date }),
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
      { { indent }, { song.title(s), "Title" } },
      { { indent }, { subtitle, "Comment" } },
      {},
      progress_chunks,
      {
        { indent },
        {
          ("Volume %s%%  ·  Random %s  ·  Repeat %s  ·  Track %d of %d"):format(
            st.volume or "?",
            st.random == "1" and "on" or "off",
            st["repeat"] ~= "1" and "off" or st.single == "1" and "song" or "queue",
            tonumber(s.Pos) + 1,
            #state.queue
          ),
          "Comment",
        },
      },
    }
    -- center the rows vertically next to the cover
    for _ = 1, math.floor((M.HEIGHT - #rows) / 2) do
      table.insert(rows, 1, {})
    end
    ui.set_chunks(bar.buf, ns, rows)
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

return M
