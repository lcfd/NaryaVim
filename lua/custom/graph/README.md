# Graph view

Obsidian's graph view for vaults edited with obsidian.nvim. You get two views of the same graph:

- **Terminal**: a floating window inside Neovim. Links are drawn with braille characters, and the layout settles live.
- **Browser**: a canvas page served by a small HTTP server running inside Neovim. Clicking a node opens the note in Neovim. The page updates live when notes change or when you switch buffers.

| Command | Keymap | |
|---|---|---|
| `:Graph` | `<leader>Gg` | global graph (terminal) |
| `:Graph local` | `<leader>Gl` | local graph of the current note (terminal) |
| `:Graph browser` | `<leader>Gb` | global graph (browser) |
| `:Graph browser local` | `<leader>GB` | local graph (browser) |
| `:Graph stop` | `<leader>Gs` | stop the server and the vault watcher |

The vault is the closest parent folder that contains `.obsidian`. If there is none, the plugin uses obsidian.nvim's current workspace, and then the cwd.

## Settings

Settings use Obsidian's own keys. Their defaults come from the vault's `.obsidian/graph.json`, so filters, color groups and forces start out the same as in the app. When you change a setting in Neovim or in the browser, only the values that differ from the app's are saved, in `stdpath("data")/graph-view/`. The vault is never written to. Changes sync live between the terminal view and any open browser tab. Restoring the defaults (`R` / ↺) drops the saved overrides.

## Feature parity

| Obsidian | Terminal | Browser |
|---|---|---|
| Search filter (`path:` `file:` `tag:` `content:` `line:` `section:`, `"phrases"`, `/regex/`, `-`, `OR`, `( )`) | `/` | ✓ |
| Tags / Attachments / Existing files only / Orphans | `t` `a` `u` `o` | ✓ |
| Color groups (query + color, first match wins) | `G` | ✓ |
| Arrows, text fade threshold, node size, link thickness | `s` (no arrows or thickness) | ✓ |
| Center / repel / link force, link distance | `s` | ✓ (live) |
| Animate (timelapse by creation date) | `A` | ✓ |
| Local graph: depth, incoming, outgoing, neighbor links | `[` `]` `i` `e` `n` | ✓ |
| Local graph follows the active note | ✓ | ✓ |
| Hover/select highlights neighbors and fades the rest | ✓ (selection) | ✓ |
| Click to open; open in a split or tab | `<CR>` `<C-v>` `<C-s>` `<C-t>`, double-click | click, ⇧-click vertical split, ⌘/ctrl-click tab, context menu |
| Drag nodes, pan, zoom | pan/zoom, mouse wheel | ✓ |
| Restore default settings | `R` | ↺ |

The browser view adds two pickers, with a fuzzy filter and a note preview:

- **⌘K** (Ctrl+K elsewhere) searches all notes. `↵` highlights the note in the graph and moves the camera to it; a note hidden by the filters opens as a local graph. `⌘↵` opens the note in Neovim, `⇧↵` opens it in a vertical split.
- **Show titles list**, in a node's right-click menu, lists the note's headings. `↵` opens the note in Neovim at that heading.

The page is fully self-contained: no CDN, fonts or third-party requests. A Content-Security-Policy blocks anything except Neovim's local server.

The terminal view also has `h j k l` to jump to the nearest node in that direction, `<Tab>` to walk along links, `c` to re-center the local graph, `f` to find a node, `T` to cycle labels and `b` to open the browser. Press `?` for the full list.

A few things differ from Obsidian:

- **Tag nodes** open a grep picker for the tag.
- **Unresolved links** open a new, unsaved note.
- **Attachments** open in the system app.
- **Search** runs a subset of Obsidian's syntax. `[property:value]`, `task:` and `block:` are not supported.

## Files

- `vault.lua`: scans the vault. It handles wikilinks, embeds, markdown links, frontmatter links and tags, and Obsidian's shortest-path link resolution. It also normalizes NFD filenames on macOS (see `unicode.lua`). Parsed notes are cached by mtime.
- `query.lua`: the search-syntax parser.
- `model.lua`: applies filters and builds the local graph. `computeView()` in `web/index.html` mirrors it.
- `physics.lua`: a d3-force style simulation (Barnes-Hut). The browser page has a JS port of it.
- `term.lua`: the braille renderer and its keymaps.
- `server.lua`: the HTTP and Server-Sent Events server. It binds to 127.0.0.1 and requires a random token on every request.
- `init.lua`: sessions, the vault watcher, commands, and opening nodes.
