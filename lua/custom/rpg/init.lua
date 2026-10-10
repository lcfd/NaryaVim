-- Solo RPG toolkit: random tables + dice roller, inspired by alexkurowski/solo-toolkit.
-- Activates when the current working directory contains an `rpg.toml` file:
--
--   tables_dir = "Tables"                                     # folder of .md random tables (default "Tables")
--   dice = ["d4", "d6", "d8", "d10", "d12", "d20", "d100"]    # optional dice list
local M = {}

local CONFIG_FILE = "rpg.toml"
local KEYMAP = "<leader>R"

M.defaults = {
  tables_dir = "Tables",
  dice = { "d4", "d6", "d8", "d10", "d12", "d20", "d100", "dF" },
}

--- The active project, or nil: { root = string, config = table }
M.project = nil

local function parse_value(raw)
  raw = vim.trim(raw)
  local quote = raw:sub(1, 1)
  if quote == '"' or quote == "'" then
    local close = raw:find(quote, 2, true)
    return raw:sub(2, (close or #raw + 1) - 1)
  end
  raw = vim.trim((raw:gsub("#.*$", "")))
  if raw == "true" or raw == "false" then
    return raw == "true"
  end
  return tonumber(raw) or raw
end

--- Minimal TOML reader: `key = value` pairs, [sections], strings, numbers, booleans, single-line arrays.
function M.parse_toml(content)
  local result, current = {}, nil
  current = result
  for line in vim.gsplit(content, "\n", { plain = true }) do
    line = vim.trim(line)
    local section = line:match("^%[([^%]]+)%]")
    if section then
      current = result
      for part in vim.gsplit(vim.trim(section), ".", { plain = true }) do
        current[part] = current[part] or {}
        current = current[part]
      end
    elseif line ~= "" and line:sub(1, 1) ~= "#" then
      local key, value = line:match("^([%w_%-]+)%s*=%s*(.+)$")
      if key then
        local array = value:match("^%[(.*)%]")
        if array then
          local items = {}
          for item in array:gmatch("[^,]+") do
            if vim.trim(item) ~= "" then
              items[#items + 1] = parse_value(item)
            end
          end
          current[key] = items
        else
          current[key] = parse_value(value)
        end
      end
    end
  end
  return result
end

local function load_config(path)
  local f = io.open(path, "r")
  if not f then
    return vim.deepcopy(M.defaults)
  end
  local content = f:read("*a")
  f:close()
  local ok, parsed = pcall(M.parse_toml, content)
  if not ok then
    vim.notify("Invalid " .. CONFIG_FILE .. ": " .. parsed, vim.log.levels.ERROR, { title = "RPG" })
    parsed = {}
  end
  local config = vim.tbl_extend("force", vim.deepcopy(M.defaults), parsed)
  if type(config.dice) ~= "table" or #config.dice == 0 then
    config.dice = vim.deepcopy(M.defaults.dice)
  end
  return config
end

function M.open()
  if not M.project then
    vim.notify("No " .. CONFIG_FILE .. " in the current directory", vim.log.levels.WARN, { title = "RPG" })
    return
  end
  -- Re-read the config so edits apply without restarting
  M.project.config = load_config(vim.fs.joinpath(M.project.root, CONFIG_FILE))
  require("custom.rpg.ui").open(M.project)
end

local function activate(root)
  M.project = { root = root, config = load_config(vim.fs.joinpath(root, CONFIG_FILE)) }
  vim.api.nvim_create_user_command("Rpg", M.open, { desc = "Open the RPG toolkit" })
  vim.keymap.set("n", KEYMAP, M.open, { desc = "[RPG] Random tables & dice." })
end

local function deactivate()
  if not M.project then
    return
  end
  M.project = nil
  pcall(vim.api.nvim_del_user_command, "Rpg")
  pcall(vim.keymap.del, "n", KEYMAP)
end

function M.detect()
  local cwd = vim.fn.getcwd()
  if vim.uv.fs_stat(vim.fs.joinpath(cwd, CONFIG_FILE)) then
    activate(cwd)
  else
    deactivate()
  end
end

local DEFAULT_CONFIG = [[
# RPG Toolkit configuration. Open the toolkit with :Rpg or <leader>R.

# Folder with the .md random tables, relative to this file. Subfolders are categories.
tables_dir = "Tables"

# Dice shown in the dice roller.
dice = ["d4", "d6", "d8", "d10", "d12", "d20", "d100", "dF"]
]]

--- Creates rpg.toml with the default configuration in the current directory.
function M.init()
  local path = vim.fs.joinpath(vim.fn.getcwd(), CONFIG_FILE)
  if vim.uv.fs_stat(path) then
    vim.notify(CONFIG_FILE .. " already exists: " .. path, vim.log.levels.WARN, { title = "RPG" })
    return
  end
  local f, err = io.open(path, "w")
  if not f then
    vim.notify("Cannot create " .. path .. ": " .. err, vim.log.levels.ERROR, { title = "RPG" })
    return
  end
  f:write(DEFAULT_CONFIG)
  f:close()
  M.detect()
  vim.notify("Created " .. path, vim.log.levels.INFO, { title = "RPG" })
end

function M.setup()
  math.randomseed(vim.uv.hrtime())
  vim.api.nvim_create_user_command("RpgInit", M.init, { desc = "Create rpg.toml in the current directory" })
  local group = vim.api.nvim_create_augroup("RpgToolkit", { clear = true })
  vim.api.nvim_create_autocmd("DirChanged", { group = group, callback = M.detect })
  M.detect()
end

return M
