-- Songs as MPD describes them: records of tags, keyed by their `file` uri.
local M = {}

---@class mpd.Song: table<string, string>
---@field file string
---@field Id? string
---@field Pos? string

--- Collects the values of a single key, e.g. the output of `list album`.
---@return string[]
function M.values(pairs_, key)
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
---@return mpd.Song[]
function M.parse(pairs_)
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

---@param s mpd.Song
function M.title(s)
  return s.Title or s.Name or vim.fn.fnamemodify(s.file, ":t")
end

---@param s mpd.Song
function M.label(s)
  local label = s.Artist and (s.Artist .. " — " .. M.title(s)) or M.title(s)
  if s.Album then
    label = label .. "  (" .. s.Album .. ")"
  end
  return label
end

return M
