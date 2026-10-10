-- Random tables engine, a port of solo-toolkit's custom tables (alexkurowski/solo-toolkit, src/view/word).
--
-- Each .md file in the tables folder is a table; subfolders are categories.
-- A roll returns a random line, unless the frontmatter defines templates like
-- `loves: "{name} loves {food}"`, where `{key}` picks from the `## Key` section,
-- another table (`{note}`, `{folder/note/section}`), a whole folder (`{folder}`),
-- or a file path relative to rpg.toml (`{/path/to/note}`).
local M = {}

local DEFAULT = "DEFAULT"
local TEMPLATE_PREFIX = "template"
local KEY_PATTERN = "{+[^}]+}+"

local function clamp(v, lo, hi)
  return math.min(math.max(v, lo), hi)
end

local function capitalize(s)
  return (s:gsub("^%l", string.upper))
end

local function unwrap(wrapped)
  return vim.trim((wrapped:gsub("[{}]", "")))
end

local function read_file(path)
  local f = io.open(path, "r")
  if not f then
    return ""
  end
  local content = f:read("*a")
  f:close()
  return (content:gsub("\r", ""))
end

local function is_dir(path)
  local stat = vim.uv.fs_stat(path)
  return stat and stat.type == "directory"
end

local function is_file(path)
  local stat = vim.uv.fs_stat(path)
  return stat and stat.type == "file"
end

local function filter(list, fn)
  return vim.tbl_filter(fn, list)
end

local function find(list, fn)
  for _, v in ipairs(list) do
    if fn(v) then
      return v
    end
  end
end

--- Loose word equality: case-insensitive, tolerant to plural forms ("food" ~ "foods", "story" ~ "stories").
local function compare_words(a, b)
  if a == nil or b == nil then
    return false
  end
  a, b = vim.trim(a):lower(), vim.trim(b):lower()
  if a == "" or b == "" then
    return a == b
  end
  return a == b or a == b .. "s" or a == (b:gsub("y$", "ies"))
end

local function find_word_key(data, key)
  for _, k in ipairs(data.order) do
    if compare_words(k, key) then
      return k
    end
  end
end

--- Splits a trailing bell-curve marker: "Clues 2d" -> "Clues", 2.
local function parse_key_with_curve(value)
  local n = value:match(" (%d+)[dD]$")
  if n then
    return vim.trim((value:gsub(" %d+[dD]$", ""))), tonumber(n)
  end
  return value, 1
end

local function normalize_template_value(str)
  if #str > 1 then
    local first = str:sub(1, 1)
    if first == str:sub(-1) and (first == "'" or first == '"') then
      str = str:sub(2, -2)
    end
  end
  return vim.trim(str)
end

--- Weighted entries: { { v = value, w = weight }, ... }
local function weighted(values)
  local out = {}
  for i, v in ipairs(values) do
    out[i] = { v = v, w = 1 }
  end
  return out
end

--- Picks a weighted entry, avoiding `avoid` when possible.
local function pick(entries, avoid)
  if #entries == 0 then
    return nil
  end
  if #entries == 1 then
    return entries[1].v
  end
  local pool = entries
  if avoid ~= nil then
    local filtered = filter(entries, function(e)
      return e.v ~= avoid
    end)
    if #filtered > 0 then
      pool = filtered
    end
  end
  local total = 0
  for _, e in ipairs(pool) do
    total = total + e.w
  end
  local r = math.random() * total
  for _, e in ipairs(pool) do
    r = r - e.w
    if r < 0 then
      return e.v
    end
  end
  return pool[#pool].v
end

--- Applies bell-curve probability: values are indexed by the sum of `curve` dice.
local function curve_values(values, curve)
  local size = #values
  if not curve or curve <= 1 or size <= 2 then
    return weighted(values)
  end
  local x = math.min(curve, 6)
  local y = math.max(math.ceil(size / x), 2)
  while x > 2 and y ^ x > 100000 do
    x = x - 1
    y = math.max(math.ceil(size / x), 2)
  end
  -- Distribution of the sum of x dice with faces 0..y-1
  local counts = { [0] = 1 }
  for _ = 1, x do
    local nxt = {}
    for s, c in pairs(counts) do
      for face = 0, y - 1 do
        nxt[s + face] = (nxt[s + face] or 0) + c
      end
    end
    counts = nxt
  end
  local out = {}
  for i, v in ipairs(values) do
    local c = counts[i - 1]
    if c and c > 0 then
      out[#out + 1] = { v = v, w = c }
    end
  end
  return out
end

--- Parses a table note.
function M.parse_content(content)
  local data = {
    mode = "default",
    templates = {},
    sections = { [DEFAULT] = {} },
    order = { DEFAULT },
    curves = {},
  }

  local lines = {}
  for _, l in ipairs(vim.split(content or "", "\n", { plain = true })) do
    l = vim.trim(l)
    if l ~= "" then
      lines[#lines + 1] = l
    end
  end

  local current
  local reading = false
  local i = 1
  while i <= #lines do
    local line = lines[i]

    if i == 1 and line == "---" then
      reading = true
    elseif reading and line == "---" then
      reading = false
    elseif reading then
      -- Frontmatter property: a template
      local colon = line:find(":", 1, true)
      local key = colon and line:sub(1, colon - 1) or ""
      local value = vim.trim(colon and line:sub(colon + 1) or line)

      if value == "|-" or value == "|" then
        i = i + 1
        local parts = {}
        while lines[i] and not lines[i]:find(":", 1, true) and lines[i] ~= "---" do
          local part = normalize_template_value(lines[i])
          if part ~= "" then
            parts[#parts + 1] = part
          end
          i = i + 1
        end
        value = table.concat(parts, "<br/>")
        i = i - 1
      end
      value = normalize_template_value(value)

      if value == "" and vim.startswith(key, TEMPLATE_PREFIX) then
        value = "{" .. DEFAULT .. "}"
      end

      if value ~= "" then
        value = value:gsub('\\"', '"'):gsub("\\'", "'")

        local times = key:match(" x(%d+)$")
        local weight = key:match(" %^(%d+)$")
        local base = vim.trim((key:gsub(" x%d+$", ""):gsub(" %^%d+$", "")))
        local template = { key = key, value = value, repeat_ = 1, weight = 1 }
        local lkey, lvalue = vim.trim(key):lower(), value:lower()

        if lkey == "mode" and (lvalue == "cutup" or lvalue == "markov") then
          data.mode = lvalue
          template = nil
        else
          if times then
            template.repeat_ = clamp(tonumber(times), 1, 20)
          end
          if weight then
            template.weight = clamp(tonumber(weight), 1, 1000)
          end
          if #base > 1 and base == base:upper() then
            template.value = lvalue
            template.upcase = true
          elseif #base > 1 and base == capitalize(base) then
            template.value = lvalue
            template.capitalize = true
          end
        end

        if template then
          for _ = 1, template.weight do
            table.insert(data.templates, template)
          end
        end
      end
    elseif line:sub(1, 1) == "#" then
      -- Headers are section keys
      local key, curve = parse_key_with_curve(vim.trim((line:gsub("#", ""))):lower())
      current = key
      if not data.sections[key] then
        table.insert(data.order, key)
      end
      data.sections[key] = {}
      data.curves[key] = curve
    elseif not line:match("^[-*_]+$") then
      -- Markdown bullets are accepted as plain lines
      line = line:gsub("^[-*+]%s+", "")
      if data.mode == "default" then
        table.insert(data.sections[DEFAULT], line)
        if current then
          table.insert(data.sections[current], line)
        end
      elseif data.mode == "cutup" then
        for word in line:gmatch("%S+") do
          table.insert(data.sections[DEFAULT], word)
        end
      elseif data.mode == "markov" then
        for word in line:gmatch("%S+") do
          word = word:gsub("[^%w']", "")
          if word ~= "" then
            table.insert(data.sections[DEFAULT], word)
          end
        end
      end
    end
    i = i + 1
  end

  -- When some templates use the prefix, other properties are not templates
  local with_prefix = filter(data.templates, function(t)
    return vim.startswith(t.key, TEMPLATE_PREFIX)
  end)
  if #with_prefix > 0 and #with_prefix < #data.templates then
    data.templates = with_prefix
  end

  -- Line weights: "pizza ^10"
  if data.mode == "default" then
    for _, key in ipairs(data.order) do
      local list = data.sections[key]
      local total = #list
      for idx = 1, total do
        local suffix = list[idx]:match(" +[%^!]%d+$")
        if suffix then
          local times = tonumber(suffix:match("%d+"))
          if times and times > 0 then
            local value = list[idx]:sub(1, #list[idx] - #suffix)
            list[idx] = value
            for _ = 1, times - 1 do
              table.insert(list, value)
            end
          end
        end
      end
    end
  end

  return data
end

local Engine = {}
Engine.__index = Engine

---@param project_root string folder containing rpg.toml
---@param tables_dir string tables folder, relative to project_root
function M.load(project_root, tables_dir)
  local self = setmetatable({
    root = project_root,
    dir = vim.fs.normalize(vim.fs.joinpath(project_root, tables_dir)),
  }, Engine)
  self:reload()
  return self
end

function Engine:reload()
  self.tables, self.refs, self.categories, self.file_cache = {}, {}, {}, {}
  self.missing = not is_dir(self.dir)
  if self.missing then
    return
  end

  local root_name = vim.fs.basename(self.dir)
  local files = {}
  for name, type in vim.fs.dir(self.dir, { depth = 10 }) do
    if
      (type == "file" or type == "link")
      and name:match("%.md$")
      and not name:match("^%.")
      and not name:find("/.", 1, true)
    then
      files[#files + 1] = name
    end
  end
  table.sort(files, function(a, b)
    return a:lower() < b:lower()
  end)

  local seen = {}
  for _, rel in ipairs(files) do
    local folder = vim.fs.dirname(rel)
    local parts = folder == "." and {} or vim.split(folder, "/", { plain = true })
    local hidden = false
    local clean = {}
    for idx, p in ipairs(parts) do
      hidden = hidden or p:match("[._]$") ~= nil
      clean[idx] = (p:gsub("[._]$", ""))
    end
    local name, curve = parse_key_with_curve((vim.fs.basename(rel):gsub("%.md$", "")))
    local data = M.parse_content(read_file(vim.fs.joinpath(self.dir, rel)))
    data.curves[DEFAULT] = curve

    local t = {
      name = name,
      rel = rel,
      category = #clean > 0 and table.concat(clean, "/") or root_name,
      tab_name = #clean > 0 and clean[#clean] or root_name,
      hidden = hidden,
      data = data,
    }
    table.insert(self.tables, t)
    if data.mode == "default" then
      table.insert(self.refs, t)
    end
    if not hidden and not seen[t.category] then
      seen[t.category] = true
      table.insert(self.categories, t.category)
    end
  end
  table.sort(self.categories, function(a, b)
    return a:lower() < b:lower()
  end)
end

function Engine:parsed(path)
  if not self.file_cache[path] then
    self.file_cache[path] = M.parse_content(read_file(path))
  end
  return self.file_cache[path]
end

---@return string[] values, number curve
function Engine:values_for_key(tbl, key)
  local data = tbl.data

  -- Sections in this file
  local sk = find_word_key(data, key)
  if sk and #data.sections[sk] > 0 then
    return data.sections[sk], data.curves[sk] or 1
  end

  -- Sections in other tables
  local parts = vim.tbl_map(vim.trim, vim.split(key, "/", { plain = true }))
  local other = find(self.refs, function(t)
    return compare_words(t.tab_name, parts[1]) and compare_words(t.name, parts[2])
  end) or find(self.refs, function(t)
    return compare_words(t.tab_name, tbl.tab_name) and compare_words(t.name, parts[1])
  end) or find(self.refs, function(t)
    return compare_words(t.name, parts[1])
  end)
  if other then
    local od = other.data
    if #parts == 1 or #od.order == 1 then
      if #od.sections[DEFAULT] > 0 then
        return od.sections[DEFAULT], od.curves[DEFAULT] or 1
      end
    end
    -- Try "section", then "note/section", ... in case the section contains '/'
    for i = 0, #parts - 1 do
      local osk = find_word_key(od, table.concat(parts, "/", #parts - i))
      if osk and #od.sections[osk] > 0 then
        return od.sections[osk], od.curves[osk] or 1
      end
    end
  end

  -- All tables in a folder
  local in_folder = filter(self.refs, function(t)
    return compare_words(t.tab_name, key)
  end)
  if #in_folder > 0 then
    local all, curve_sum = {}, 0
    for _, t in ipairs(in_folder) do
      vim.list_extend(all, t.data.sections[DEFAULT])
      curve_sum = curve_sum + (t.data.curves[DEFAULT] or 1)
    end
    if #all > 0 then
      return all, math.max(1, math.floor(curve_sum / #in_folder + 0.5))
    end
  end

  -- Note titles (folder/*) or contents (folder/!) in a folder
  if #parts == 2 and (parts[2] == "*" or parts[2] == "!") then
    local out = {}
    for _, t in ipairs(self.refs) do
      if compare_words(t.tab_name, parts[1]) then
        out[#out + 1] = parts[2] == "*" and t.name or table.concat(t.data.sections[DEFAULT], "\n")
      end
    end
    if #out > 0 then
      return out, 1
    end
  end

  return {}, 1
end

function Engine:values_for_keys(tbl, keys_str)
  local out = {}
  for _, key in ipairs(vim.split(keys_str, "|", { plain = true })) do
    local values, curve = self:values_for_key(tbl, vim.trim(key))
    vim.list_extend(out, curve_values(values, curve))
  end
  if #out == 0 then
    return { { v = "{" .. keys_str .. "}", w = 1 } }
  end
  return out
end

--- Resolves `{/path/to/note}` keys, relative to the folder containing rpg.toml.
function Engine:values_for_path(key)
  local path = key:gsub("^/", ""):gsub("/%*$", ""):gsub("/!$", ""):gsub("/$", "")
  local abs = vim.fs.joinpath(self.root, path)

  local function md_files(dir)
    local out = {}
    if not is_dir(dir) then
      return out
    end
    for name, type in vim.fs.dir(dir) do
      if (type == "file" or type == "link") and name:match("%.md$") then
        out[#out + 1] = vim.fs.joinpath(dir, name)
      end
    end
    table.sort(out)
    return out
  end

  local values = {}
  if key:match("/%*$") then
    for _, f in ipairs(md_files(abs)) do
      values[#values + 1] = (vim.fs.basename(f):gsub("%.md$", ""))
    end
  elseif key:match("/!$") then
    for _, f in ipairs(md_files(abs)) do
      values[#values + 1] = table.concat(self:parsed(f).sections[DEFAULT], "\n")
    end
  else
    local file, section
    local files = md_files(abs)
    if #files > 0 then
      file = files[math.random(#files)]
    elseif is_file(abs .. ".md") then
      file = abs .. ".md"
    elseif is_file(vim.fs.dirname(abs) .. ".md") then
      file = vim.fs.dirname(abs) .. ".md"
      section = vim.fs.basename(abs)
    end
    if file then
      local data = self:parsed(file)
      local sk = section and find_word_key(data, section)
      values = (sk and #data.sections[sk] > 0) and data.sections[sk] or data.sections[DEFAULT]
    end
  end

  if #values == 0 then
    return { "{" .. key .. "}" }
  end
  return values
end

--- Replaces a key with a word; `last` remembers picks so `{<key}` repeats them.
function Engine:replace_key_with_word(tbl, wrapped, last)
  local raw = unwrap(wrapped)
  local key = raw:lower()
  if key == "" then
    return ""
  end
  if key:sub(1, 1) == "<" then
    raw = vim.trim(raw:sub(2))
    key = raw:lower()
    if last[key] then
      return last[key]
    end
  end
  local entries
  if key:sub(1, 1) == "/" then
    entries = weighted(self:values_for_path(raw))
  else
    entries = self:values_for_keys(tbl, key)
  end
  local value = pick(entries, last[key])
  last[key] = value
  return value
end

--- Expands keys pointing to a folder into one of its tables' templates, scoped to that table.
function Engine:replace_key_with_template(tbl, wrapped)
  local key = unwrap(wrapped):lower()
  if key == "" then
    return ""
  end
  -- Path keys are case-sensitive
  if key:sub(1, 1) == "/" then
    return wrapped
  end

  local wanted
  local tables = filter(self.refs, function(t)
    return compare_words(t.tab_name, key)
  end)
  if #tables == 0 and key:find("/", 1, true) then
    -- folder/template
    local slash = key:match(".*()/")
    local folder = key:sub(1, slash - 1)
    wanted = key:sub(slash + 1)
    tables = filter(self.refs, function(t)
      return compare_words(t.tab_name, folder)
    end)
  end

  if #tables > 0 then
    local t = tables[math.random(#tables)]
    if #t.data.templates == 0 then
      return "{" .. t.tab_name .. "/" .. t.name .. "}"
    end
    local template = t.data.templates[math.random(#t.data.templates)].value
    if wanted then
      local w = find(t.data.templates, function(tpl)
        return compare_words(wanted, tpl.key)
      end)
      if w then
        template = w.value
      end
    end
    -- Give each foreign key the folder/note context
    template = template:gsub(KEY_PATTERN, function(sub_wrapped)
      local sub = unwrap(sub_wrapped):lower()
      if sub:find("|", 1, true) then
        local options = vim.split(sub, "|", { plain = true })
        sub = vim.trim(options[math.random(#options)])
      end
      if sub:find("/", 1, true) then
        return "{" .. sub .. "}"
      end
      if find_word_key(t.data, sub) then
        return "{" .. t.tab_name .. "/" .. t.name .. "/" .. sub .. "}"
      end
      return "{" .. sub .. "}"
    end)
    if template ~= "" then
      return template
    end
  end
  return "{" .. key .. "}"
end

function Engine:expand(tbl, text, last, template)
  local result = text
  for _ = 1, 5 do
    local new = result:gsub(KEY_PATTERN, function(w)
      return self:replace_key_with_template(tbl, w)
    end)
    if new == result then
      break
    end
    result = new
  end
  for _ = 1, 5 do
    local new = result:gsub(KEY_PATTERN, function(w)
      return self:replace_key_with_word(tbl, w, last)
    end)
    if new == result then
      break
    end
    result = new
  end
  -- {a} becomes "a" or "an" based on the next word
  local source = result
  result = source:gsub("(){+ ?a ?}+()", function(_, e)
    local nxt = source:sub(e):match("%a")
    if nxt then
      return nxt:lower():match("[aeiou]") and "an" or "a"
    end
  end)
  result = vim.trim(result)

  if template and template.capitalize then
    result = capitalize(result)
  elseif template and template.upcase then
    result = result:upper()
  end
  return result
end

local function random_int(lo, hi)
  return hi < lo and lo or math.random(lo, hi)
end

--- Rolls a table.
---@return string[] results (usually one, more with `key xN` templates)
function Engine:generate(tbl)
  local data = tbl.data
  local words = data.sections[DEFAULT]

  if data.mode == "cutup" then
    if #words == 0 then
      return {}
    end
    local len = math.random(2, 6) + math.random(2, 6)
    local start = random_int(1, #words - len)
    return { table.concat(words, " ", start, math.min(#words, start + len - 1)) }
  elseif data.mode == "markov" then
    if #words == 0 then
      return {}
    end
    local len = math.random(4, 8) + math.random(4, 8)
    local result = { words[math.random(#words)] }
    for i = 1, len do
      local nexts = {}
      for idx = 2, #words do
        if compare_words(words[idx - 1], result[i]) then
          nexts[#nexts + 1] = words[idx]
        end
      end
      local pool = #nexts > 0 and nexts or words
      result[#result + 1] = pool[math.random(#pool)]
    end
    return { table.concat(result, " ") }
  end

  local raw = {}
  if #data.templates > 0 then
    local template = data.templates[math.random(#data.templates)]
    local last = {}
    for _ = 1, template.repeat_ do
      raw[#raw + 1] = self:expand(tbl, template.value, last, template)
    end
  else
    local line = pick(self:values_for_keys(tbl, DEFAULT))
    raw[1] = self:expand(tbl, line, {}, nil)
  end

  local results = {}
  for _, value in ipairs(raw) do
    value = value:gsub("< ?[bB][rR] ?/? ?>", "\n"):gsub("\\n", "\n")
    if value ~= "" and value:lower() ~= "{" .. DEFAULT:lower() .. "}" then
      results[#results + 1] = value
    end
  end
  return results
end

return M
