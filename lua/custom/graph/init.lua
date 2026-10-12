-- Obsidian-style graph view for vaults edited with obsidian.nvim.
--
--   :Graph                  global graph in a floating window (braille canvas)
--   :Graph local            local graph of the current note
--   :Graph browser [local]  same graph in the browser, served from Neovim:
--                           clicking a node opens the note here, and the page
--                           updates live when notes change
--   :Graph stop             stop the browser server and the vault watcher
--
-- Settings start from the vault's `.obsidian/graph.json` (filters, color
-- groups, forces) and are shared between the terminal and browser views.
local M = {}

local uv = vim.uv
local vault = require("custom.graph.vault")
local settings_store = require("custom.graph.settings")
local query = require("custom.graph.query")

M.options = {
  -- bring the terminal to the front when a note is opened from the browser
  focus_terminal = true,
}

---@class graph.Session
---@field root string
---@field graph graph.Graph
---@field settings table
---@field active string|nil  id of the note in the current buffer
---@field server graph.Server|nil
---@field watcher uv.uv_fs_event_t|nil
---@field listeners table<integer, fun(event: string)>

---@type table<string, graph.Session>
local sessions = {}
local next_listener = 0

local Session = {}
Session.__index = Session

local function emit(session, event, data)
  for _, fn in pairs(session.listeners) do
    pcall(fn, event)
  end
  if session.server then
    session.server.broadcast(event, data or {})
  end
end

function Session:subscribe(fn)
  next_listener = next_listener + 1
  local id = next_listener
  self.listeners[id] = fn
  return function()
    self.listeners[id] = nil
  end
end

function Session:refresh()
  self.graph = vault.scan(self.root)
  emit(self, "graph")
end

function Session:update_settings(changes, opts)
  self.settings = vim.tbl_extend("force", self.settings, changes)
  settings_store.save(self.root, self.settings)
  emit(self, "settings", (opts or {}).from_browser and { from_browser = true } or {})
end

function Session:reset_settings()
  self.settings = settings_store.reset(self.root)
  emit(self, "settings")
end

function Session:set_active(id)
  if id ~= self.active then
    self.active = id
    emit(self, "active", { id = id })
  end
end

--- The node id of a buffer's file when it belongs to this vault.
function Session:node_id(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr or 0)
  if name == "" then
    return nil
  end
  name = vim.fs.normalize(name)
  if vim.startswith(name, self.root .. "/") then
    local rel = name:sub(#self.root + 2)
    if self.graph.index[rel] then
      return rel
    end
  end
  return nil
end

-- Re-scans the vault (debounced) whenever a file in it changes, including
-- edits made by the Obsidian app or git. Dot-folders (.obsidian, .git) are ignored.
function Session:watch()
  if self.watcher then
    return
  end
  local watcher = uv.new_fs_event()
  local timer = uv.new_timer()
  if not watcher or not timer then
    return
  end
  local ok = watcher:start(self.root, { recursive = true }, function(err, filename)
    if err or (filename and (filename:match("^%.") or filename:match("/%.") or filename:match("~$"))) then
      return
    end
    timer:stop()
    timer:start(300, 0, function()
      vim.schedule(function()
        if sessions[self.root] == self then
          self:refresh()
        end
      end)
    end)
  end)
  if ok then
    self.watcher = watcher
    self.watch_timer = timer
  end
end

function Session:stop()
  if self.server then
    self.server.close()
    self.server = nil
  end
  if self.watcher then
    self.watcher:stop()
    self.watcher:close()
    self.watch_timer:close()
    self.watcher = nil
  end
end

--- Returns the session for the vault containing the current buffer.
---@return graph.Session
function M.session(root)
  root = vim.fs.normalize(root or vault.find_root(vim.api.nvim_buf_get_name(0)))
  local session = sessions[root]
  if not session then
    session = setmetatable({
      root = root,
      graph = vault.scan(root),
      settings = settings_store.load(root),
      listeners = {},
    }, Session)
    sessions[root] = session
    session.active = session:node_id(0)
    session:watch()
  end
  return session
end

-- Picks the window notes should open in: the current one unless it is a
-- floating window or a special buffer, then the first regular window.
local function main_window()
  local function usable(win)
    local buf = vim.api.nvim_win_get_buf(win)
    return vim.api.nvim_win_get_config(win).relative == "" and vim.bo[buf].buftype == ""
  end
  local current = vim.api.nvim_get_current_win()
  if usable(current) then
    return current
  end
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if usable(win) then
      return win
    end
  end
  return current
end

--- Opens a graph node: notes in Neovim, attachments in the system app,
--- tags in a grep picker and unresolved links as a new note.
---@param mode? "edit"|"split"|"vsplit"|"tab"
---@param line? integer  1-based line to put the cursor on
function M.open_node(session, node, mode, line)
  mode = mode or "edit"
  if node.type == "attachment" and not node.path:match("%.md$") and not node.path:match("%.canvas$") then
    vim.ui.open(session.root .. "/" .. node.path)
    return
  end
  if node.type == "tag" then
    local ok, snacks = pcall(require, "snacks")
    if ok then
      snacks.picker.grep({ search = node.name, cwd = session.root })
    else
      vim.cmd("vimgrep /" .. vim.fn.escape(node.name, "/") .. "/j " .. vim.fn.fnameescape(session.root) .. "/**/*.md")
      vim.cmd.copen()
    end
    return
  end
  local path = node.path and (session.root .. "/" .. node.path) or (session.root .. "/" .. node.name .. ".md")
  local win = main_window()
  vim.api.nvim_set_current_win(win)
  local cmd = ({ edit = "edit", split = "split", vsplit = "vsplit", tab = "tabedit" })[mode] or "edit"
  vim.cmd(cmd .. " " .. vim.fn.fnameescape(path))
  if line then
    pcall(vim.api.nvim_win_set_cursor, 0, { line, 0 })
    vim.cmd("normal! zt")
  end
end

--- A note's lines and Markdown headings (outside code blocks), for the
--- browser's note preview and headings picker.
local function note_json(session, node)
  local lines = {}
  if node.path and node.type == "note" then
    local f = io.open(session.root .. "/" .. node.path, "r")
    if f then
      for l in f:lines() do
        lines[#lines + 1] = l
      end
      f:close()
    end
  end
  local headings, fence = {}, nil
  for n, l in ipairs(lines) do
    local marker = l:match("^%s*(```)") or l:match("^%s*(~~~)")
    if marker then
      fence = (fence == nil) and marker or (fence == marker and nil or fence)
    elseif not fence and not (n == 1 and l == "---") then
      local hashes, text = l:match("^(#+)%s+(.-)%s*#*%s*$")
      if hashes and #hashes <= 6 and text ~= "" then
        headings[#headings + 1] = { level = #hashes, text = text, line = n }
      end
    end
  end
  return vim.json.encode({ lines = lines, headings = headings })
end

local function focus_terminal()
  local bundle = vim.env.__CFBundleIdentifier
  if M.options.focus_terminal and vim.fn.has("mac") == 1 and bundle then
    vim.system({ "open", "-b", bundle })
  end
end

--- Graph payload for the browser: nodes, links (0-based) and the active note.
local function graph_json(session)
  local nodes = {}
  for i, node in ipairs(session.graph.nodes) do
    nodes[i] = { id = node.id, name = node.name, type = node.type, path = node.path, ctime = node.ctime }
  end
  local links = {}
  for i, link in ipairs(session.graph.links) do
    links[i] = { link[1] - 1, link[2] - 1 }
  end
  return vim.json.encode({
    vault = vim.fs.basename(session.root),
    nodes = nodes,
    links = links,
    active = session.active,
  })
end

local html_cache
local function page()
  if not html_cache then
    local dir = vim.fs.dirname(debug.getinfo(1, "S").source:sub(2))
    local f = assert(io.open(dir .. "/web/index.html", "r"))
    html_cache = f:read("*a")
    f:close()
  end
  return html_cache
end

local function start_server(session)
  if session.server then
    return session.server
  end
  local json = "application/json"
  session.server = require("custom.graph.server").start({
    ["GET /"] = function()
      return 200, "text/html; charset=utf-8", page()
    end,
    ["GET /api/graph"] = function()
      return 200, json, graph_json(session)
    end,
    ["GET /api/settings"] = function()
      return 200, json, vim.json.encode(session.settings)
    end,
    ["POST /api/settings"] = function(req)
      session:update_settings(vim.json.decode(req.body), { from_browser = true })
      return 204, "text/plain", ""
    end,
    ["POST /api/settings/reset"] = function()
      session:reset_settings()
      return 200, json, vim.json.encode(session.settings)
    end,
    -- evaluates search/color-group queries: { queries = string[] } -> (int[]|null)[]
    ["POST /api/match"] = function(req)
      local results = {}
      for i, q in ipairs(vim.json.decode(req.body).queries or {}) do
        local set = query.match(session.graph, q)
        if set then
          local list = {}
          for idx in pairs(set) do
            list[#list + 1] = idx - 1
          end
          results[i] = list
        else
          results[i] = vim.NIL
        end
      end
      return 200, json, vim.json.encode(results)
    end,
    ["GET /api/note"] = function(req)
      local idx = session.graph.index[req.params.id or ""]
      if not idx then
        return 404, "text/plain", "unknown node"
      end
      return 200, json, note_json(session, session.graph.nodes[idx])
    end,
    ["POST /api/open"] = function(req)
      local body = vim.json.decode(req.body)
      local idx = session.graph.index[body.id]
      if not idx then
        return 404, "text/plain", "unknown node"
      end
      M.open_node(session, session.graph.nodes[idx], body.mode, tonumber(body.line))
      focus_terminal()
      return 204, "text/plain", ""
    end,
  })
  return session.server
end

--- Opens the browser view.
function M.browser(opts)
  opts = opts or {}
  local session = M.session()
  local server = start_server(session)
  if not server then
    return
  end
  local url = server.url
  if opts.local_graph then
    if not session:node_id(0) then
      vim.notify("Graph: the current buffer is not a note of " .. session.root, vim.log.levels.WARN)
      return
    end
    url = url .. "&local=1"
  end
  vim.ui.open(url)
  vim.notify("Graph view: " .. url, vim.log.levels.INFO, { title = "Graph" })
end

--- Opens the terminal view.
function M.open(opts)
  opts = opts or {}
  local session = M.session()
  if opts.local_graph then
    if not session:node_id(0) then
      vim.notify("Graph: the current buffer is not a note of " .. session.root, vim.log.levels.WARN)
      return
    end
  end
  require("custom.graph.term").open(session, { local_graph = opts.local_graph })
end

function M.stop()
  for root, session in pairs(sessions) do
    session:stop()
    sessions[root] = nil
  end
end

function M.setup(opts)
  M.options = vim.tbl_extend("force", M.options, opts or {})

  vim.api.nvim_create_user_command("Graph", function(cmd)
    local args = {}
    for _, a in ipairs(cmd.fargs) do
      args[a] = true
    end
    if args.stop then
      local running = not vim.tbl_isempty(sessions)
      M.stop()
      vim.notify(running and "Graph server stopped" or "Graph server is not running", vim.log.levels.INFO)
    elseif args.browser then
      M.browser({ local_graph = args["local"] })
    else
      M.open({ local_graph = args["local"] })
    end
  end, {
    nargs = "*",
    desc = "Obsidian-style graph view",
    complete = function()
      return { "local", "browser", "stop" }
    end,
  })

  local group = vim.api.nvim_create_augroup("custom.graph", { clear = true })
  -- local graphs and the browser follow the note being edited
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    callback = function(ev)
      for _, session in pairs(sessions) do
        local id = session:node_id(ev.buf)
        if id then
          session:set_active(id)
        end
      end
    end,
  })
  -- the watcher catches saves too, but a direct refresh is immediate
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = "*.md",
    callback = function(ev)
      local name = vim.fs.normalize(vim.api.nvim_buf_get_name(ev.buf))
      for root, session in pairs(sessions) do
        if vim.startswith(name, root .. "/") then
          session:refresh()
          session:set_active(session:node_id(ev.buf))
        end
      end
    end,
  })
  vim.api.nvim_create_autocmd("VimLeavePre", { group = group, callback = M.stop })
end

return M
