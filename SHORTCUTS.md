# Shortcuts

Leader key is `<Space>`. This list covers the shortcuts worth knowing day-to-day; it's not exhaustive of every default Neovim/plugin binding.

## Custom (NaryaVim-specific)

These are hand-written in `lua/config/keymaps.lua` and aren't defaults you'd find in a stock config.

| Shortcut | Action |
|---|---|
| `;` | Open command-line (`:`) without needing Shift |
| `<C-j>` | Save current buffer |
| `H` | Go to start of line |
| `L` | Go to end of line |
| `\` | Split window vertically |
| `\|` | Close window |
| `<C-h>` / `<C-l>` | Move to window left / right |
| `<leader>ff` | Format file (or visual range) — conform.nvim |
| `<leader>rn` | LSP rename |
| `<leader>ca` | LSP code action |
| `<leader>lj` | Show diagnostic float for element under cursor |
| `[d` / `]d` | Previous / next diagnostic |
| `<leader>S` | Toggle Spectre (project-wide find & replace) |
| `<leader>sw` | Spectre: search current word (normal & visual) |
| `<leader>sp` | Spectre: search current word in current file |
| `<leader>tc` | Pick text case for word/selection (custom textcase picker) |
| `<leader>o` | Open parent directory (Oil.nvim) |
| `=` | Harpoon quick menu |
| `-` | Harpoon: add current file |
| `<leader>1`–`<leader>9` | Jump to Harpoon file 1–9 |

## Terminal

| Shortcut | Action |
|---|---|
| `<C-\>` | Toggle floating terminal (toggleterm.nvim) |
| `<leader>gg` | Open Lazygit (floating) |

## Files & Search (snacks.nvim pickers)

| Shortcut | Action |
|---|---|
| `<leader><space>` | Find files |
| `<leader>p` | File explorer |
| `<leader>fo` | Recent files |
| `<leader>fi` | Search in current buffer |
| `<leader>fw` | Grep word in project |
| `<leader>fW` | Grep visual selection / word under cursor |
| `<leader>fr` | Resume last picker |
| `<leader>gt` | TODO/FIX/FIXME picker |
| `xx` | Delete current buffer |
| `xa` | Delete other buffers |

## Git

| Shortcut | Action |
|---|---|
| `<leader>gg` | Lazygit |
| `<leader>gb` | Git blame current line |
| `<leader>gf` | Lazygit file history (current file) |

## LSP & Diagnostics

| Shortcut | Action |
|---|---|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gr` | Find references |
| `gi` | Go to implementation |
| `gy` | Go to type definition |
| `gai` | Incoming calls |
| `gao` | Outgoing calls |
| `<leader>ds` | LSP document symbols |
| `<leader>dS` | LSP workspace symbols |
| `<leader>lk` | Buffer diagnostics list |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code action |
| `[d` / `]d` | Previous / next diagnostic |

## Navigation & Text Objects (treesitter, via snacks)

| Shortcut | Action |
|---|---|
| `if` / `af` | Inner / outer function |
| `ic` / `ac` | Inner / outer class |
| `ia` / `aa` | Inner / outer parameter |
| `im` / `am` | Inner / outer function call |
| `ii` / `ai` | Inner / outer conditional/scope block |
| `il` / `al` | Inner / outer loop block |
| `]m` / `[m` | Next / previous function start |
| `]M` / `[M` | Next / previous function end |
| `]s` / `[s` | Next / previous scope block |

## Editing & Docs

| Shortcut | Action |
|---|---|
| `<leader>nf` | Generate docstring for function (neogen) |
| `<leader>nc` | Generate docstring for class (neogen) |
| `<leader>tt` | Toggle checkbox (Obsidian, markdown files) |

## UI Toggles

| Shortcut | Action |
|---|---|
| `<leader>z` | Toggle Zen Mode |
| `<leader>us` | Toggle spell check |

## Python

| Shortcut | Action |
|---|---|
| `<leader>vs` | Select virtualenv (VenvSelector) |
| `<leader>vc` | Select cached virtualenv |
