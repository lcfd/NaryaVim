-- Graph settings, using Obsidian's own keys. Defaults come from the vault's
-- `.obsidian/graph.json` so the graph looks the same as in the app; changes
-- made from Neovim are stored separately and never touch the vault.
local M = {}

M.defaults = {
  -- filters
  search = "",
  showTags = false,
  showAttachments = false,
  hideUnresolved = false,
  showOrphans = true,
  -- groups: { query = string, color = { a = number, rgb = integer } }
  colorGroups = {},
  -- display
  showArrow = false,
  textFadeMultiplier = 0,
  nodeSizeMultiplier = 1,
  lineSizeMultiplier = 1,
  -- forces
  centerStrength = 0.518713248970312,
  repelStrength = 10,
  linkStrength = 1,
  linkDistance = 250,
  -- local graph (Obsidian keeps these per view)
  localJumps = 1,
  localBacklinks = true,
  localForelinks = true,
  localInterlinks = false,
}

local function state_file(root)
  local name = root:gsub("[/\\:]", "%%")
  return vim.fn.stdpath("data") .. "/graph-view/" .. name .. ".json"
end

local function read_json(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local data = f:read("*a")
  f:close()
  local ok, decoded = pcall(vim.json.decode, data, { luanil = { object = true, array = true } })
  return ok and type(decoded) == "table" and decoded or nil
end

local function pick(source)
  local out = {}
  for k in pairs(M.defaults) do
    if source[k] ~= nil then
      out[k] = source[k]
    end
  end
  return out
end

--- Settings as configured in the Obsidian app, without local overrides.
function M.obsidian(root)
  return vim.tbl_extend("force", vim.deepcopy(M.defaults), pick(read_json(root .. "/.obsidian/graph.json") or {}))
end

function M.load(root)
  return vim.tbl_extend("force", M.obsidian(root), pick(read_json(state_file(root)) or {}))
end

--- Stores only the settings that differ from the Obsidian app's, so later
--- changes made in Obsidian still apply to the rest.
function M.save(root, settings)
  local base = M.obsidian(root)
  local diff = {}
  for k, v in pairs(pick(settings)) do
    if not vim.deep_equal(v, base[k]) then
      diff[k] = v
    end
  end
  local path = state_file(root)
  if vim.tbl_isempty(diff) then
    os.remove(path)
    return
  end
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local f = io.open(path, "w")
  if f then
    f:write(vim.json.encode(diff))
    f:close()
  end
end

--- Forgets local overrides, going back to the Obsidian app's settings.
function M.reset(root)
  os.remove(state_file(root))
  return M.obsidian(root)
end

return M
