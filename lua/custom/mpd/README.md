# MPD

A small [MPD](https://www.musicpd.org/) client for Neovim. It speaks the MPD
protocol directly over TCP or a unix socket (via `vim.uv`), so it needs neither
`mpc` nor Telescope, and uses [snacks.nvim](https://github.com/folke/snacks.nvim)
pickers for its UI. It started as a port of
[paulfrische/mpd.nvim](https://github.com/paulfrische/mpd.nvim).

- [Requirements](#requirements)
- [Configuration](#configuration)
- [Keymaps](#keymaps)
- [Command Center](#command-center)
- [Playlists](#playlists)
- [Statusline](#statusline)
- [Cover art](#cover-art)
- [API](#api)
- [Structure](#structure)

## Requirements

- Neovim 0.10+
- [snacks.nvim](https://github.com/folke/snacks.nvim)
- A running MPD server
- Optional, for cover art: a terminal with the kitty graphics protocol and
  unicode placeholders (Ghostty, kitty), and
  [ImageMagick](https://imagemagick.org/) (`magick` or `convert`) to shrink the
  queue thumbnails

## Configuration

The server is read from the same environment variables `mpc` uses, falling back
to MPD's defaults:

| Option | Default | Notes |
|--------|---------|-------|
| `host` | `$MPD_HOST` or `127.0.0.1` | A path starting with `/` is a unix socket |
| `port` | `$MPD_PORT` or `6600` | Ignored for unix sockets |

To override them from Lua:

```lua
require("custom.mpd").setup({ host = "/run/mpd/socket" })
```

## Keymaps

Defined in `lua/config/keymaps.lua`:

| Keys | Action |
|------|--------|
| `<leader>mm` | Open the Command Center |
| `<leader>ms` | Add a song to the queue |
| `<leader>ma` | Add an album to the queue |
| `<leader>ml` | Open the Playlists |
| `<leader>mp` | Play / pause |
| `<leader>mn` | Next track |
| `<leader>mb` | Previous track |
| `<leader>mc` | Show the song that's playing |

## Command Center

`<leader>mm` opens a full-screen view of the player:

```
╭─ Queue · 12 ──────────────╮╭─ Details ─────────────────╮
│ search                    ││          (cover)          │
│───────────────────────────││        Song title         │
│ ▣ 1  Artist — Song (Alb)  ││  Artist   …               │
│ ▣ 󰝚  Artist — Song (Alb)  ││  Queue    2 of 12         │
│ ▣ 3  Artist — Song (Alb)  │╰───────────────────────────╯
│                           │╭─ Actions ─────────────────╮
│                           ││ 󰐎  Play / Pause         p │
│                           ││ …                         │
╰───────────────────────────╯╰───────────────────────────╯
╭─ Now Playing ─────────────────────────────────────────╮
│ (cover)  Title · Artist · Album · progress · volume   │
╰───────────────────────────────────────────────────────╯
```

- **Queue** (left): every song in the queue, each with a small cover. The song
  that's playing shows `󰝚` in place of its number. Typing filters the queue.
- **Details** (right, top): cover and tags of the selected song, and its
  position in the queue. While the Actions panel is focused, or when the queue
  is empty, it lists the shortcuts.
- **Actions** (right, bottom): every command, with its shortcut.
- **Now Playing** (bottom): the current song with its cover, a progress bar,
  and the volume, random and repeat state.

The view refreshes every second, so changes made by other clients show up too.

### Shortcuts

Action shortcuts work in every panel (in the search box, in normal mode):

| Key | Action |
|-----|--------|
| `p` | Play / pause |
| `n` / `N` | Next / previous track |
| `l` / `h` | Forward / back 10 seconds |
| `r` | Toggle random |
| `R` | Toggle repeat queue |
| `o` | Toggle repeat song |
| `s` | Add a song (opens a picker) |
| `a` | Add an album (opens a picker) |
| `P` | Add a playlist (opens a picker) |
| `S` | Shuffle the queue |
| `C` | Clear the queue |
| `u` | Update the library: scan for new, changed and removed files |
| `U` | Rescan the library: re-read every file, even unchanged ones |

Library updates run in the background: you're notified when they start and
again when MPD finishes.

Navigation:

| Key | Where | Action |
|-----|-------|--------|
| `1` | anywhere | Focus the Queue |
| `2` | anywhere | Focus the Actions |
| `<CR>` | Queue | Play the selected song |
| `<CR>` | Actions | Run the selected action |
| `d` / `<C-d>` | Queue | Remove the selected song from the queue |
| `i` or `/` | anywhere | Search the queue |
| `q` / `<Esc>` | Actions | Close |

Add Song, Add Album and Add Playlist close the Command Center while you pick,
and bring it back when you're done (or cancel).

## Playlists

`<leader>ml` opens the stored playlists, laid out like the Command Center:

```
╭─ Playlists · 3 ───╮╭─ Songs ─────────────────────╮╭─ Details ───────────╮
│ search            ││ ▣ 1  Artist — Song (Album)  ││       (cover)       │
│───────────────────││ ▣ 2  Artist — Song (Album)  ││    Playlist name    │
│ 󰲸  Chill          ││ ▣ 3  Artist — Song (Album)  ││  Songs     24       │
│ 󰲸  Road trip      ││                             ││  Duration  1:32:10  │
│ 󰲸  Workout        ││                             ││  Artists   …        │
╰───────────────────╯╰─────────────────────────────╯╰─────────────────────╯
```

- **Playlists** (left): every stored playlist. Typing filters them.
- **Songs** (middle): the songs of the selected playlist, each with a small
  cover.
- **Details** (right): follows the focus. On the playlists it shows the
  playlist: the cover of its first song, how many songs and how long, its main
  artists and when it last changed. On the songs it shows the song under the
  cursor and its position in the playlist. `?` shows the shortcuts instead.

### Shortcuts

These work in both panels (in the search box, in normal mode), on the selected
playlist:

| Key | Action |
|-----|--------|
| `n` | New playlist: asks for a name, then for its first song |
| `S` | Save the queue as a new playlist |
| `r` | Rename the playlist |
| `D` | Delete the playlist (asks first) |
| `L` | Add the playlist to the queue |
| `P` | Play the playlist: replaces the queue |
| `a` | Add a song to the playlist (opens a picker) |
| `A` | Add an album to the playlist (opens a picker) |
| `C` | Remove every song from the playlist (asks first) |
| `?` | Toggle the shortcuts in Details |

In the Songs panel, on the song under the cursor:

| Key | Action |
|-----|--------|
| `d` | Remove it from the playlist |
| `K` / `J` | Move it up / down |
| `<CR>` | Add it to the queue |

Navigation:

| Key | Where | Action |
|-----|-------|--------|
| `1` | anywhere | Focus the Playlists |
| `2` | anywhere | Focus the Songs |
| `<CR>` | Playlists | Focus the Songs |
| `i` or `/` | anywhere | Search the playlists |
| `q` / `<Esc>` | anywhere | Close |

MPD has no empty playlists: a playlist exists once it has a song, so `n` goes
straight to picking the first one. Cancel that picker and nothing is created.

## Statusline

`require("custom.mpd").statusline()` returns the title of the playing song,
prefixed with `󰝚` (playing) or `󰏤` (paused). It's polled every 2 seconds in the
background, starting with the first call. It's empty when nothing plays, when
MPD isn't running, or when the window is too narrow, and it's truncated to at
most 40 columns. It's wired into lualine in `lua/plugins/lualine.lua`:

```lua
{
  function()
    return require("custom.mpd").statusline()
  end,
  cond = function()
    return require("custom.mpd").statusline() ~= ""
  end,
}
```

## Cover art

Covers come from the picture embedded in the file (`readpicture`), falling back
to a cover file in the song's directory (`albumart`). They're cached in
`stdpath("cache")/mpd-covers` (`~/.cache/nvim/mpd-covers`), next to two kinds
of copies:

- `*.bar.*`, the Now Playing cover. Ghostty draws every placement of an image
  at the size of its latest one, so the bar needs its own copy, otherwise the
  Details cover would resize it.
- `*.thumb.png`, the 64×64 queue thumbnail, shared by the songs of an album.

Thumbnails only load for the songs on screen. Delete the cache directory to
fetch covers again.

Snacks detects Ghostty from its reply to an XTVERSION query. When that reply is
missed, the module falls back to Ghostty's environment variables.

## API

Everything is on `require("custom.mpd")`. Functions taking `cb` call it once
MPD has answered.

| Function | Description |
|----------|-------------|
| `setup(opts)` | Override the [configuration](#configuration) |
| `command_center()` | Open the [Command Center](#command-center) |
| `playlists()` | Open the [Playlists](#playlists) |
| `find_song(name?)` / `find_album(name?)` | Pick a song / album to add to the queue, or to the playlist `name` |
| `find_playlist()` | Pick a playlist to add to the queue |
| `play()` / `pause()` / `toggle(cb)` | Playback |
| `next(cb)` / `prev(cb)` | Change track |
| `seek(delta, cb)` | Seek by `delta` seconds, relative to the current position |
| `shuffle(cb)` / `clear(cb)` | Shuffle / clear the queue |
| `toggle_random(cb)` | Toggle random |
| `toggle_repeat(cb)` / `toggle_repeat_song(cb)` | Toggle repeat queue / song |
| `update_library(cb)` / `rescan_library(cb)` | Start a library update / full rescan |
| `current()` | Notify the song that's playing |
| `statusline()` | See [Statusline](#statusline) |
| `cover(file, cb)` | Resolve a song's cover to a local image path (`nil` if none) |
| `request(cmds, cb, on_error)` | Send raw protocol commands |
| `playlist.*` | Stored playlists: `list`, `songs`, `load`, `play`, `save_queue`, `add`, `add_album`, `remove`, `move`, `clear`, `rename`, `delete` (see `playlist.lua`) |

`request` takes a command string (`"status"`), a command with arguments
(`{ "add", file }`; arguments are quoted for you), or a list of those, sent as
one command list. `cb(pairs, binary)` gets the response as a list of
`{ key, value }` pairs, plus the payload of a `binary:` response if any.
Errors are notified unless you pass `on_error`.

```lua
require("custom.mpd").request({ { "status" }, { "currentsong" } }, function(res)
  for _, kv in ipairs(res) do
    print(kv[1], kv[2])
  end
end)
```

## Structure

`init.lua` is the public API and only re-exports. The core modules don't need
Snacks, so the statusline can load at startup; the `ui/` modules are loaded
when first used.

| Module | Role |
|--------|------|
| `init.lua` | Public API |
| `config.lua` | Options and `setup()` |
| `client.lua` | MPD protocol over TCP / unix socket (`request`) |
| `song.lua` | Parsing responses into songs; titles and labels |
| `player.lua` | Playback, queue and library commands; `state()` (status + queue) |
| `playlist.lua` | Stored playlists |
| `cover.lua` | Cover art fetching and disk cache |
| `statusline.lua` | Background-polled statusline text |
| `util.lua` | Notifications, time and date formatting |
| `ui/modal.lua` | Which modal is open; lets pickers leave it and come back |
| `ui/center.lua` | The Command Center: picker layout, keys, refresh loop |
| `ui/playlists.lua` | The Playlists modal: layout, keys, songs panel |
| `ui/queue.lua` | Queue items and row formatting |
| `ui/thumbs.lua` | Queue thumbnails (kitty unicode placeholders) |
| `ui/details.lua` | Details panel: song or playlist cover and tags, markdown |
| `ui/panel.lua` | A focusable float filling an empty box of a picker layout |
| `ui/actions.lua` | Actions panel of the Command Center |
| `ui/commands.lua` | The list of actions and their shortcuts |
| `ui/bar.lua` | Now Playing bar |
| `ui/pickers.lua` | Add Song / Album / Playlist pickers |
| `ui/util.lua` | Float, buffer and image-support helpers |

To add an action, add it to `ui/commands.lua`: the Actions panel, the
shortcuts and the Details shortcut list all pick it up. Playlist shortcuts live
in the `keys` table of `ui/playlists.lua`, which also feeds its `?` help.

Snacks pickers only lay out their own three windows (search, list, preview).
Extra panels, like Actions and Songs, reserve their place with an empty
bordered box in the layout (`panel.box(title)`), and `ui/panel.lua` opens a
focusable float over it.
