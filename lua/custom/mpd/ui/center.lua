-- Command center: the queue on the left; the selected song's details (or the
-- shortcuts, while in the actions) over the actions on the right; and a "now
-- playing" bar at the bottom spanning the whole width.
local actions = require("custom.mpd.ui.actions")
local bar = require("custom.mpd.ui.bar")
local client = require("custom.mpd.client")
local commands = require("custom.mpd.ui.commands")
local details = require("custom.mpd.ui.details")
local modal = require("custom.mpd.ui.modal")
local player = require("custom.mpd.player")
local queue = require("custom.mpd.ui.queue")
local thumbs = require("custom.mpd.ui.thumbs")
local util = require("custom.mpd.util")

local M = {}

local center -- the open command center picker, if any

---@param state mpd.State
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
    "- `<CR>`  Run action / play song",
    "- `i` or `/`  Search the queue",
    "- `1` / `2`  Focus queue / actions",
    "",
    ("**Queue**: %d tracks · %s"):format(#state.queue, util.fmt_time(total)),
  })
  return lines
end

function M.open()
  if center and not center.closed then
    return
  end
  local state ---@type mpd.State
  local timer = assert(vim.uv.new_timer())
  local now_playing = bar.new()
  local panel -- the actions panel
  local in_actions = false -- the actions panel has focus: details show the shortcuts
  local closing = false -- Snacks only marks the picker closed after `on_close`
  local resize_au

  local function preview(ctx)
    details.reset(ctx.preview)
    if in_actions then
      return details.markdown(ctx.preview, shortcuts(state))
    end
    local s = ctx.item.song
    details.song(ctx.preview, s, {
      current = state.current ~= nil and s.Id == state.current.Id,
      position = { "Queue", tonumber(s.Pos) + 1, #state.queue },
    })
  end

  local picker
  local function refresh()
    player.state(function(new)
      if not picker or picker.closed then
        return
      end
      local changed = new.status.playlist ~= state.status.playlist
        or new.status.songid ~= state.status.songid
        or new.status.state ~= state.status.state
      state = new
      now_playing.render(state)
      if changed then
        picker.title = queue.title(state)
        picker:update_titles()
        -- new items re-trigger the preview on their own
        picker:refresh()
      end
    end)
  end

  ---@param cmd mpd.Command
  local function run(cmd)
    if cmd.leaves then
      cmd.fn()
    else
      cmd.fn(refresh)
    end
  end

  local function remove(_, item)
    if item then
      client.request({ "deleteid", item.song.Id }, refresh)
    end
  end

  local function focus_queue()
    picker:focus("list")
  end

  local function focus_actions()
    panel.focus()
  end

  local function search()
    picker:focus("input")
    vim.cmd.startinsert()
  end

  -- shortcuts work in every panel, and in the search box's normal mode
  local picker_actions = { mpd_remove = remove, mpd_focus_queue = focus_queue, mpd_focus_actions = focus_actions }
  local list_keys = {
    ["d"] = { "mpd_remove", desc = "Remove from queue" },
    ["<c-d>"] = { "mpd_remove", desc = "Remove from queue" },
    ["1"] = { "mpd_focus_queue", desc = "Focus queue" },
    ["2"] = { "mpd_focus_actions", desc = "Focus actions" },
  }
  local input_keys = {
    ["d"] = { "mpd_remove", mode = "n", desc = "Remove from queue" },
    ["<c-d>"] = { "mpd_remove", mode = { "n", "i" }, desc = "Remove from queue" },
    ["1"] = { "mpd_focus_queue", mode = "n", desc = "Focus queue" },
    ["2"] = { "mpd_focus_actions", mode = "n", desc = "Focus actions" },
  }
  for _, cmd in ipairs(commands) do
    if cmd.key then
      local name = "mpd_" .. cmd.key
      picker_actions[name] = function()
        run(cmd)
      end
      list_keys[cmd.key] = { name, desc = cmd.text }
      input_keys[cmd.key] = { name, mode = "n", desc = cmd.text }
    end
  end

  panel = actions.new({
    run = run,
    keys = {
      ["1"] = focus_queue,
      ["2"] = function() end,
      ["q"] = function()
        picker:close()
      end,
      ["<Esc>"] = function()
        picker:close()
      end,
      ["i"] = search,
      ["/"] = search,
    },
    on_focus = function(focused)
      in_actions = focused
      -- closing the panel leaves it: don't redraw a picker that's going away
      if not (closing or picker.closed) then
        picker.preview:show(picker, { force = true })
      end
    end,
  })

  player.state(function(initial)
    state = initial
    picker = Snacks.picker({
      title = queue.title(state),
      finder = function()
        return queue.items(state)
      end,
      format = queue.format,
      preview = preview,
      focus = "list",
      show_empty = true, -- an empty queue still has the actions
      layout = {
        layout = {
          box = "horizontal",
          width = 0.8,
          min_width = 120,
          -- leave room below for the now playing bar
          height = function()
            return math.floor(vim.o.lines * 0.8) - (bar.HEIGHT + 2)
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
          {
            box = "vertical",
            width = 0.5,
            { win = "preview", title = "{preview}", border = true },
            -- filled by the actions panel
            actions.box(),
          },
        },
      },
      -- with an empty queue there's nothing to preview: show the shortcuts,
      -- once Snacks has reset the preview
      on_change = function(p, item)
        if not item then
          vim.schedule(function()
            if not p.closed and not p:current() and p.preview.win:valid() then
              details.reset(p.preview)
              details.markdown(p.preview, shortcuts(state))
              p:update_titles()
            end
          end)
        end
      end,
      confirm = function(_, item)
        if item then
          client.request({ "playid", item.song.Id }, refresh)
        end
      end,
      on_show = function(p)
        vim.schedule(function()
          if p.closed then
            return
          end
          now_playing.open(p)
          now_playing.render(state)
          panel.open(p)
          resize_au = vim.api.nvim_create_autocmd("VimResized", {
            callback = function()
              -- after Snacks has re-laid out the picker
              vim.schedule(function()
                now_playing.reposition(p)
                now_playing.render(state)
                panel.reposition(p)
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
        if center == p then
          center = nil
          thumbs.on_update = nil
        end
        timer:stop()
        timer:close()
        now_playing.close()
        panel.close()
        if resize_au then
          pcall(vim.api.nvim_del_autocmd, resize_au)
        end
        if p.preview and p.preview.win and p.preview.win.buf then
          pcall(Snacks.image.placement.clean, p.preview.win.buf)
        end
      end,
    })
    center = picker
    modal.set({ picker = picker, reopen = M.open })
    -- redraw the queue as its thumbnails load
    thumbs.on_update = function()
      if not picker.closed then
        picker.list:update({ force = true })
      end
    end
    timer:start(1000, 1000, vim.schedule_wrap(refresh))
  end)
end

return M
