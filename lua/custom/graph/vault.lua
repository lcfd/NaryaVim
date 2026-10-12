-- Vault scanner: walks an Obsidian vault and builds the link graph the way
-- Obsidian's graph view does (notes, attachments, tags, unresolved links).
-- Parsed files are cached by mtime so rescans only re-read what changed.
local M = {}

local uv = vim.uv
local nfc = require("custom.graph.unicode").nfc

--- Case- and normalization-insensitive comparison key.
local function key(s)
  return vim.fn.tolower(nfc(s))
end

---@class graph.Node
---@field id string         stable key: vault-relative path, "#tag" or "?linkpath"
---@field name string       label shown in the graph
---@field path string|nil   vault-relative path (notes and attachments)
---@field type "note"|"attachment"|"tag"|"unresolved"
---@field ctime integer     creation time, used by the timelapse animation
---@field tags string[]|nil lowercase tags without "#" (notes only)

---@class graph.Graph
---@field root string
---@field nodes graph.Node[]
---@field index table<string, integer> node id -> position in `nodes`
---@field links integer[][]  { source_index, target_index }, deduplicated
---@field content table<string, string> note id -> lowercase content (for queries)

local cache = {} ---@type table<string, { mtime: integer, links: string[], tags: string[], content: string }>

local function read_file(path)
  local f = io.open(path, "rb")
  if not f then
    return nil
  end
  local data = f:read("*a")
  f:close()
  return data
end

local function url_decode(s)
  return (s:gsub("%%(%x%x)", function(hex)
    return string.char(tonumber(hex, 16))
  end))
end

--- Removes fenced code blocks and inline code, where links and tags don't count.
local function strip_code(text)
  local out, in_fence = {}, false
  for line in vim.gsplit(text, "\n", { plain = true }) do
    if line:match("^%s*```") or line:match("^%s*~~~") then
      in_fence = not in_fence
      out[#out + 1] = ""
    elseif in_fence then
      out[#out + 1] = ""
    else
      out[#out + 1] = (line:gsub("``.-``", ""):gsub("`[^`]*`", ""))
    end
  end
  return table.concat(out, "\n")
end

local function split_frontmatter(text)
  local fm, body = text:match("^%-%-%-\r?\n(.-)\r?\n%-%-%-[ \t]*\r?\n(.*)$")
  if fm then
    return fm, body
  end
  return nil, text
end

--- Values of a YAML key in either `key: [a, b]`, `key: a, b` or block-list form.
local function frontmatter_list(fm, key)
  local values = {}
  local lines = vim.split(fm, "\r?\n")
  for i, line in ipairs(lines) do
    local rest = line:match("^" .. key .. ":%s*(.*)$")
    if rest then
      rest = vim.trim(rest)
      if rest ~= "" then
        for item in rest:gsub("^%[", ""):gsub("%]$", ""):gmatch("[^,]+") do
          values[#values + 1] = item
        end
      else
        for j = i + 1, #lines do
          local item = lines[j]:match("^%s*%-%s*(.+)$")
          if not item then
            break
          end
          values[#values + 1] = item
        end
      end
    end
  end
  local cleaned = {}
  for _, v in ipairs(values) do
    v = vim.trim(v):gsub("^[\"']", ""):gsub("[\"']$", ""):gsub("^#", "")
    if v ~= "" then
      cleaned[#cleaned + 1] = v
    end
  end
  return cleaned
end

local function is_tag(tag)
  -- a tag needs at least one non-numeric character
  return tag ~= "" and not tag:match("^[%d/]+$")
end

--- Extracts raw link targets and tags from a note's text.
function M.parse(text)
  local links, tags = {}, {}
  local fm, body = split_frontmatter(text)

  if fm then
    for _, tag in ipairs(frontmatter_list(fm, "tags")) do
      tags[#tags + 1] = tag
    end
    for _, tag in ipairs(frontmatter_list(fm, "tag")) do
      tags[#tags + 1] = tag
    end
    -- Obsidian resolves wikilinks inside frontmatter properties too
    for target in fm:gmatch("%[%[([^%]]+)%]%]") do
      links[#links + 1] = target
    end
  end

  body = strip_code(body)

  for target in body:gmatch("%[%[([^%]\n]+)%]%]") do
    links[#links + 1] = target
  end

  for target in body:gmatch("%]%(([^%)\n]+)%)") do
    target = vim.trim(target):gsub("^<(.*)>$", "%1"):gsub('%s+".*"$', "")
    if not target:match("^%a[%w+.-]*:") and not target:match("^#") then
      links[#links + 1] = url_decode(target)
    end
  end

  for line in vim.gsplit(body, "\n", { plain = true }) do
    for tag in (" " .. line):gmatch("%s#([^%s#%.,;:!%?%(%)%[%]{}\"'`|*<>=+~&\\]+)") do
      if is_tag(tag) then
        tags[#tags + 1] = tag
      end
    end
  end

  local seen, unique_tags = {}, {}
  for _, tag in ipairs(tags) do
    tag = key(tag):gsub("/$", "")
    if is_tag(tag) and not seen[tag] then
      seen[tag] = true
      unique_tags[#unique_tags + 1] = tag
    end
  end
  return links, unique_tags
end

--- Lists vault files (relative paths), skipping dot-folders and macOS resource forks.
local function list_files(root)
  local files = {}
  for name, type in
    vim.fs.dir(root, {
      depth = math.huge,
      skip = function(dir)
        return not vim.fs.basename(dir):match("^%.")
      end,
    })
  do
    local base = vim.fs.basename(name)
    if type == "file" and not base:match("^%.") then
      files[#files + 1] = name
    end
  end
  table.sort(files)
  return files
end

--- Builds a resolver that maps a link target to a file id, following
--- Obsidian's rules: exact vault path, then path relative to the note, then
--- the shortest-path file whose path ends with the link (case-insensitive).
local function make_resolver(files)
  local by_path, by_name = {}, {}
  for _, rel in ipairs(files) do
    local lower = key(rel)
    by_path[lower] = rel
    local base = key(vim.fs.basename(rel))
    by_name[base] = by_name[base] or {}
    table.insert(by_name[base], rel)
  end
  for _, list in pairs(by_name) do
    table.sort(list, function(a, b)
      return #a < #b or (#a == #b and a < b)
    end)
  end

  return function(linkpath, from)
    local lower = key(linkpath):gsub("^%./", ""):gsub("^/", "")
    local has_ext = vim.fs.basename(lower):match("%.[%w]+$") ~= nil
    local candidates = { lower }
    if not has_ext then
      candidates = { lower .. ".md", lower }
    end
    local from_dir = vim.fs.dirname(key(from))
    for _, c in ipairs(candidates) do
      if by_path[c] then
        return by_path[c]
      end
      if from_dir ~= "." then
        local relative = vim.fs.normalize(from_dir .. "/" .. c)
        if by_path[relative] then
          return by_path[relative]
        end
      end
    end
    for _, c in ipairs(candidates) do
      local list = by_name[vim.fs.basename(c)]
      if list then
        -- prefer a file in the same folder as the linking note
        for _, rel in ipairs(list) do
          if vim.fs.dirname(key(rel)) == from_dir and key(rel):sub(-#c) == c then
            return rel
          end
        end
        for _, rel in ipairs(list) do
          if key(rel):sub(-#c) == c then
            return rel
          end
        end
      end
    end
    return nil
  end
end

local function display_name(rel)
  local base = nfc(vim.fs.basename(rel))
  if base:match("%.md$") then
    return (base:gsub("%.md$", ""))
  end
  return base
end

--- Scans the vault at `root` and returns the graph.
---@return graph.Graph
function M.scan(root)
  root = vim.fs.normalize(root)
  local files = list_files(root)
  local resolve = make_resolver(files)

  local graph = { root = root, nodes = {}, index = {}, links = {}, content = {} }
  local function add_node(node)
    if not graph.index[node.id] then
      graph.nodes[#graph.nodes + 1] = node
      graph.index[node.id] = #graph.nodes
    end
    return graph.index[node.id]
  end

  local parsed = {}
  for _, rel in ipairs(files) do
    local abs = root .. "/" .. rel
    local stat = uv.fs_stat(abs)
    local ctime = stat and (stat.birthtime and stat.birthtime.sec > 0 and stat.birthtime.sec or stat.mtime.sec) or 0
    local is_note = rel:match("%.md$") ~= nil
    add_node({
      id = rel,
      name = display_name(rel),
      path = rel,
      type = is_note and "note" or "attachment",
      ctime = ctime,
    })
    if is_note and stat then
      local entry = cache[abs]
      if not entry or entry.mtime ~= stat.mtime.sec * 1e9 + stat.mtime.nsec then
        local text = read_file(abs) or ""
        local links, tags = M.parse(text)
        entry = {
          mtime = stat.mtime.sec * 1e9 + stat.mtime.nsec,
          links = links,
          tags = tags,
          content = vim.fn.tolower(text),
        }
        cache[abs] = entry
      end
      parsed[rel] = entry
    end
  end

  local seen_links = {}
  local function add_link(a, b)
    if a == b then
      return
    end
    local key = a .. ":" .. b
    if not seen_links[key] then
      seen_links[key] = true
      graph.links[#graph.links + 1] = { a, b }
    end
  end

  for _, rel in ipairs(files) do
    local entry = parsed[rel]
    if entry then
      local source = graph.index[rel]
      graph.nodes[source].tags = entry.tags
      graph.content[rel] = entry.content
      for _, raw in ipairs(entry.links) do
        local linkpath = vim.trim((raw:gsub("|.*$", ""):gsub("#.*$", ""):gsub("%^.*$", "")))
        if linkpath ~= "" then
          local target = resolve(linkpath, rel)
          if target then
            add_link(source, graph.index[target])
          else
            local id = "?" .. key(linkpath)
            add_link(
              source,
              add_node({ id = id, name = nfc(vim.fs.basename(linkpath)), type = "unresolved", ctime = 0 })
            )
          end
        end
      end
      for _, tag in ipairs(entry.tags) do
        add_link(source, add_node({ id = "#" .. tag, name = "#" .. tag, type = "tag", ctime = 0 }))
      end
    end
  end

  -- tags and unresolved links appear in the timelapse with their first note
  for _, link in ipairs(graph.links) do
    local a, b = graph.nodes[link[1]], graph.nodes[link[2]]
    if b.type == "tag" or b.type == "unresolved" then
      if b.ctime == 0 or a.ctime < b.ctime then
        b.ctime = a.ctime
      end
    end
  end

  -- drop cache entries of deleted files
  for abs in pairs(cache) do
    if vim.startswith(abs, root .. "/") and not graph.index[abs:sub(#root + 2)] then
      cache[abs] = nil
    end
  end

  return graph
end

local function contains(dir, path)
  dir = vim.fs.normalize(dir)
  return path == dir or vim.startswith(path, dir .. "/")
end

--- Finds the vault for `path`: the closest folder with `.obsidian`, then
--- obsidian.nvim's current workspace if `path` is inside it. Plain markdown
--- folders work too: a project root (.git, .marksman.toml, ...) other than
--- $HOME, else the cwd when it contains `path`, else the file's own folder.
function M.find_root(path)
  local cwd = vim.fs.normalize(vim.fn.getcwd())
  if path == "" then
    return vim.fs.root(cwd, ".obsidian") or cwd
  end
  path = vim.fs.normalize(path)
  local root = vim.fs.root(path, ".obsidian")
  if root then
    return root
  end
  local ok, workspace = pcall(function()
    return tostring(_G.Obsidian.workspace.root)
  end)
  if ok and workspace and contains(workspace, path) then
    return vim.fs.normalize(workspace)
  end
  root = vim.fs.root(path, { ".git", ".hg", ".svn", ".jj", ".marksman.toml" })
  if root and vim.fs.normalize(root) ~= vim.fs.normalize(vim.uv.os_homedir()) then
    return vim.fs.normalize(root)
  end
  if contains(cwd, path) and cwd ~= vim.fs.normalize(vim.uv.os_homedir()) then
    return cwd
  end
  return vim.fs.dirname(path)
end

return M
