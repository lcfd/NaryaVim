-- blink.cmp source: `[[` wikilink completion for markdown notes outside any
-- project. marksman only indexes a workspace containing one of its markers
-- (.git/.hg/.svn/.jj/.marksman.toml) and obsidian.nvim covers vaults; in
-- every other folder marksman runs in single-file mode and suggests nothing,
-- so this source lists the .md files next to (and below) the current note.

-- marksman's workspace markers plus Obsidian vaults
local covered_markers = { ".git", ".hg", ".svn", ".jj", ".marksman.toml", ".obsidian" }
local max_depth = 4
local max_files = 2000

-- true when marksman or obsidian.nvim already completes wikilinks here
local function is_covered(bufnr)
  local root = vim.fs.root(bufnr, covered_markers)
  -- a .git at $HOME (dotfiles repo) is ignored by the marksman config in
  -- plugins/lsp.lua, so marksman runs in single-file mode there too
  return root ~= nil and root ~= vim.uv.os_homedir()
end

local function list_notes(dir)
  local notes = {}
  for name, type in
    vim.fs.dir(dir, {
      depth = max_depth,
      skip = function(dir_name)
        return not dir_name:match("^%.")
      end,
    })
  do
    if type == "file" and name:match("%.md$") then
      notes[#notes + 1] = name:gsub("%.md$", "")
      if #notes >= max_files then
        break
      end
    end
  end
  return notes
end

local source = {}

function source.new()
  return setmetatable({}, { __index = source })
end

function source:enabled()
  return vim.bo.filetype == "markdown" and not is_covered(0)
end

function source:get_trigger_characters()
  return { "[" }
end

function source:get_completions(ctx, callback)
  local col = ctx.cursor[2]
  local before = ctx.line:sub(1, col)
  local typed = before:match("%[%[([^%[%]|#]*)$")
  if not typed then
    callback({ items = {}, is_incomplete_forward = false, is_incomplete_backward = false })
    return
  end

  local file = vim.api.nvim_buf_get_name(ctx.bufnr)
  local self_name = vim.fn.fnamemodify(file, ":t:r")
  -- don't add the closing brackets when autopairs already inserted them
  local close = ctx.line:sub(col + 1, col + 2) == "]]" and "" or "]]"
  local range = {
    start = { line = ctx.cursor[1] - 1, character = col - #typed },
    ["end"] = { line = ctx.cursor[1] - 1, character = col },
  }

  local items = {}
  for _, note in ipairs(list_notes(vim.fs.dirname(file))) do
    if note ~= self_name then
      items[#items + 1] = {
        label = note,
        kind = require("blink.cmp.types").CompletionItemKind.File,
        textEdit = { newText = note .. close, range = range },
      }
    end
  end
  callback({ items = items, is_incomplete_forward = false, is_incomplete_backward = false })
end

return source
