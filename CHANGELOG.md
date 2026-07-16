# Changelog

## 2026-07-16

- Migrate `nvim-treesitter` config to the new `main`-branch API (parser install via `install()`, highlighting/indent enabled via a `FileType` autocmd) — the old `setup()` call was passing a legacy options schema that the new branch silently ignored, so highlighting/indent/auto-install were effectively no-ops. Requires the `tree-sitter` CLI (not just `libtree-sitter`) on `$PATH` for parser compilation.
- Fix `lua/plugins/oil.lua` `show_idden` typo (`show_hidden`), so hidden files actually show in Oil.
- Fix neotest venv path missing a `/` separator (`lua/plugins/testing.lua`).
- Fix `neogen` `typescript`/`typescriptreact` language config being nested incorrectly, so `tsdoc` annotations never applied.
- Replace deprecated `vim.loop.fs_stat` with `vim.uv.fs_stat` in `lua/config/lazy.lua`.
- Remove the blanket `vim.deprecate = function() end` override in `lua/config/options.lua` so future deprecation warnings surface again.
- Drop unused `neovim/nvim-lspconfig` dependency from `lua/plugins/lsp.lua` (only native `vim.lsp.config`/`vim.lsp.enable` are used).
- Remove dead code: unused `lua/utils/map.lua` and `lua/utils/merge.lua`, orphaned `lua/plugins/treesitter/config_movements.lua`, no-op `lua/plugins/ai.lua` and `lua/plugins/init.lua`, and stale commented-out plugin specs/keymaps/commands across `keymaps.lua`, `commands.lua`, `git.lua`, `markdown.lua`, `plugins/utils/init.lua`, and `python.lua`.
- Remove stray `lua/custom/django-cotton.zip` and `.DS_Store`.

## 2023-04-27

- Try `folke/which-key.nvim`.
- Try to fix leap and textcase overlap (gas not working).

## 2023-04-24

- Added debugger for Python and JavaScript. Both to attach and launch a file.
- Add keybindings for debuggers. They will probably change after intensive tests in the near future.
- Re-add `MunifTanjim/nui.nvim` for custom Narya plugins.

## 2023-04-20

- Add support keybindings to split windows and move through them.
