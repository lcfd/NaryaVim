-- Terminal graph view: a floating window drawing the graph with braille
-- characters (2x4 dots per cell) for links, glyphs for nodes and text labels.
-- The layout runs live (physics.lua) and the view follows vault changes.
local M = {}

local uv = vim.uv
local api = vim.api
local model = require("custom.graph.model")
local physics = require("custom.graph.physics")

local ns = api.nvim_create_namespace("custom.graph.term")
local FRAME_MS = 33
local TICKS_PER_FRAME = 2

local function set_highlights()
  local links = {
    GraphLink = "NonText",
    GraphLinkActive = "Function",
    GraphNode = "Comment",
    GraphLabel = "Normal",
    GraphDim = "NonText",
    GraphTag = "String",
    GraphAttachment = "DiagnosticWarn",
    GraphUnresolved = "NonText",
    GraphActive = "Special",
    GraphSelected = "CurSearch",
    GraphHeader = "Title",
  }
  for name, target in pairs(links) do
    api.nvim_set_hl(0, name, { link = target, default = true })
  end
end

local group_hls = {}
local function group_hl(rgb)
  local name = string.format("GraphGroup%06x", rgb)
  if not group_hls[name] then
    api.nvim_set_hl(0, name, { fg = string.format("#%06x", rgb) })
    group_hls[name] = true
  end
  return name
end

-- braille dot bits, indexed [dx][dy] inside a 2x4 cell
local DOTS = { [0] = { [0] = 0x01, 0x02, 0x04, 0x40 }, [1] = { [0] = 0x08, 0x10, 0x20, 0x80 } }
local braille = {}
for bits = 0, 255 do
  braille[bits] = vim.fn.nr2char(0x2800 + bits)
end

local char_cache = {}
--- Splits a label into display cells: { char, width }.
local function label_chars(text)
  local cached = char_cache[text]
  if cached then
    return cached
  end
  local chars = {}
  for _, ch in ipairs(vim.fn.split(text, "\\zs")) do
    chars[#chars + 1] = { ch, vim.fn.strdisplaywidth(ch) }
  end
  char_cache[text] = chars
  return chars
end

local View = {}
View.__index = View

local HELP = {
  { "h j k l", "select the nearest node in that direction" },
  { "<Tab> <S-Tab>", "walk to the next/previous linked node" },
  { "<CR>", "open the selected node (<C-v> vsplit, <C-s> split, <C-t> tab)" },
  { "c", "local graph centered on the selected node" },
  { "g", "toggle global / local graph" },
  { "[ ]", "local graph depth" },
  { "i e n", "local graph: incoming / outgoing / neighbor links" },
  { "/", "search filter (Obsidian syntax: path: tag: file: -term OR …)" },
  { "f", "find a node by name" },
  { "t a u o", "toggle tags / attachments / unresolved / orphans" },
  { "G", "color groups" },
  { "s", "all settings (forces, display, filters)" },
  { "A", "animate (timelapse by creation date)" },
  { "H J K L / arrows", "pan" },
  { "+ - / scroll", "zoom   0  fit" },
  { "r", "reheat the layout" },
  { "R", "restore the vault's Obsidian settings" },
  { "b", "open the same graph in the browser" },
  { "q <Esc>", "close" },
}

function View:graph()
  return self.session.graph
end

function View:center_index()
  if not self.local_graph then
    return nil
  end
  local id = self.center or self.session.active
  return id and self:graph().index[id] or nil
end

--- Recomputes the visible graph and the simulation, keeping node positions.
function View:rebuild(alpha)
  local graph = self:graph()
  local settings = self.session.settings
  local center = self:center_index()
  if self.local_graph and not center then
    self.local_graph = false
  end
  self.view = model.view(graph, settings, center)

  -- timelapse: only nodes created up to the current reveal step
  if self.reveal then
    local order = vim.deepcopy(self.view.nodes)
    table.sort(order, function(a, b)
      return graph.nodes[a].ctime < graph.nodes[b].ctime
    end)
    local shown = {}
    for k = 1, math.min(self.reveal, #order) do
      shown[order[k]] = true
    end
    self.view.nodes = vim.tbl_filter(function(i)
      return shown[i]
    end, self.view.nodes)
    self.view.links = vim.tbl_filter(function(l)
      return shown[l[1]] and shown[l[2]]
    end, self.view.links)
    self.reveal_total = #order
  end

  local slot = {}
  local sim_nodes = {}
  for k, i in ipairs(self.view.nodes) do
    slot[i] = k
    local id = graph.nodes[i].id
    local p = self.positions[id]
    if not p then
      p = {}
      self.positions[id] = p
    end
    sim_nodes[k] = p
  end
  local sim_links = {}
  local degree = {}
  self.neighbors = {}
  for _, l in ipairs(self.view.links) do
    local a, b = slot[l[1]], slot[l[2]]
    sim_links[#sim_links + 1] = { a, b }
    degree[l[1]] = (degree[l[1]] or 0) + 1
    degree[l[2]] = (degree[l[2]] or 0) + 1
    self.neighbors[l[1]] = self.neighbors[l[1]] or {}
    self.neighbors[l[2]] = self.neighbors[l[2]] or {}
    table.insert(self.neighbors[l[1]], l[2])
    table.insert(self.neighbors[l[2]], l[1])
  end
  -- new nodes start next to a positioned neighbor instead of the origin
  for k, i in ipairs(self.view.nodes) do
    local p = sim_nodes[k]
    if not p.x then
      for _, j in ipairs(self.neighbors[i] or {}) do
        local q = self.positions[graph.nodes[j].id]
        if q and q.x then
          p.x, p.y = q.x + (math.random() - 0.5) * 30, q.y + (math.random() - 0.5) * 30
          break
        end
      end
    end
  end
  if center and slot[center] then
    local p = sim_nodes[slot[center]]
    p.x, p.y = p.x or 0, p.y or 0
  end
  self.degree = degree
  self.slot = slot
  self.sim = physics.new(sim_nodes, sim_links, physics.forces(settings))
  self.sim.alpha = alpha or 1
  if self.selected and not slot[self.selected] then
    self.selected = nil
  end
  self:start()
end

function View:start()
  if self.timer:is_active() then
    return
  end
  self.timer:start(
    0,
    FRAME_MS,
    vim.schedule_wrap(function()
      if not api.nvim_win_is_valid(self.win) then
        self:close()
        return
      end
      local running = false
      for _ = 1, TICKS_PER_FRAME do
        running = self.sim:tick() or running
      end
      if self.follow then
        self:fit()
      end
      self:render()
      if not running and not self.reveal then
        self.timer:stop()
      end
    end)
  )
end

function View:size()
  return api.nvim_win_get_width(self.win), api.nvim_win_get_height(self.win)
end

function View:fit()
  local nodes = self.sim.nodes
  if #nodes == 0 then
    self.cx, self.cy, self.zoom = 0, 0, 1
    return
  end
  local x0, y0, x1, y1 = math.huge, math.huge, -math.huge, -math.huge
  for _, n in ipairs(nodes) do
    x0, y0, x1, y1 = math.min(x0, n.x), math.min(y0, n.y), math.max(x1, n.x), math.max(y1, n.y)
  end
  local w, h = self:size()
  -- leave room for labels on the right
  local dw, dh = math.max(w - 16, 4) * 2, math.max(h - 2, 2) * 4
  self.cx, self.cy = (x0 + x1) / 2, (y0 + y1) / 2
  self.zoom = math.min(dw / math.max(x1 - x0, 1), dh / math.max(y1 - y0, 1), 1.5)
end

--- Screen cell (0-based col/row) of a world position.
function View:to_cell(x, y)
  local w, h = self:size()
  local px = (x - self.cx) * self.zoom + w -- dots: 2 per column
  local py = (y - self.cy) * self.zoom + h * 2 -- dots: 4 per row
  return math.floor(px / 2), math.floor(py / 4), px, py
end

function View:node_hl(i)
  local node = self:graph().nodes[i]
  if node.id == self.session.active then
    return "GraphActive"
  end
  local rgb = self.view.colors[i]
  if rgb then
    return group_hl(rgb)
  end
  return ({ tag = "GraphTag", attachment = "GraphAttachment", unresolved = "GraphUnresolved" })[node.type]
    or "GraphNode"
end

function View:render()
  if not api.nvim_buf_is_valid(self.buf) then
    return
  end
  local w, h = self:size()
  local dw, dh = w * 2, h * 4
  local bits, link_hl = {}, {}
  for r = 0, h - 1 do
    bits[r], link_hl[r] = {}, {}
  end

  local graph, settings = self:graph(), self.session.settings
  local focus = self.selected
  local related = {}
  if focus then
    related[focus] = true
    for _, j in ipairs(self.neighbors[focus] or {}) do
      related[j] = true
    end
  end

  local function plot(px, py, hl)
    if px >= 0 and py >= 0 and px < dw and py < dh then
      local col, row = math.floor(px / 2), math.floor(py / 4)
      local cell = bits[row]
      cell[col] = bit.bor(cell[col] or 0, DOTS[px % 2][py % 4])
      if hl then
        link_hl[row][col] = true
      end
    end
  end

  -- links: clip to the canvas (Liang-Barsky), then step along the line
  local sim_nodes = self.sim.nodes
  for k, l in ipairs(self.sim.links) do
    local a, b = sim_nodes[l[1]], sim_nodes[l[2]]
    local _, _, x0, y0 = self:to_cell(a.x, a.y)
    local _, _, x1, y1 = self:to_cell(b.x, b.y)
    local dx, dy = x1 - x0, y1 - y0
    local t0, t1 = 0, 1
    local visible = true
    for _, edge in ipairs({ { -dx, x0 }, { dx, dw - 1 - x0 }, { -dy, y0 }, { dy, dh - 1 - y0 } }) do
      local p, q = edge[1], edge[2]
      if p == 0 then
        if q < 0 then
          visible = false
        end
      else
        local t = q / p
        if p < 0 then
          t0 = math.max(t0, t)
        else
          t1 = math.min(t1, t)
        end
      end
    end
    if visible and t0 <= t1 then
      local sx, sy = x0 + dx * t0, y0 + dy * t0
      local ex, ey = x0 + dx * t1, y0 + dy * t1
      local steps = math.max(math.abs(ex - sx), math.abs(ey - sy))
      local link = self.view.links[k]
      local hl = focus and (link[1] == focus or link[2] == focus)
      for s = 0, math.ceil(steps) do
        local t = steps > 0 and s / steps or 0
        plot(math.floor(sx + (ex - sx) * t + 0.5), math.floor(sy + (ey - sy) * t + 0.5), hl)
      end
    end
  end

  -- cells: { text, hl } per column; nodes and labels go over links
  local cells = {}
  for r = 0, h - 1 do
    local row = {}
    for c = 0, w - 1 do
      local b = bits[r][c]
      if b then
        row[c] = { braille[b], link_hl[r][c] and "GraphLinkActive" or "GraphLink" }
      else
        row[c] = { " " }
      end
    end
    cells[r] = row
  end

  local size = settings.nodeSizeMultiplier
  local fade = 0.35 * 1.6 ^ (settings.textFadeMultiplier or 0)
  local occupied = {}
  local labels = {}
  for k, i in ipairs(self.view.nodes) do
    local n = sim_nodes[k]
    local col, row = self:to_cell(n.x, n.y)
    if col >= 0 and row >= 0 and col < w and row < h then
      local deg = self.degree[i] or 0
      local radius = size * (1 + math.sqrt(deg) * 0.6) * self.zoom * 4
      local glyph = radius < 3 and "·" or (radius < 7 and "•" or "●")
      local hl = self:node_hl(i)
      if focus and not related[i] then
        hl = "GraphDim"
      end
      if i == focus then
        hl = "GraphSelected"
      end
      cells[row][col] = { glyph, hl }
      occupied[row * w + col] = true
      local priority = (i == focus and 3)
        or (related[i] and focus and 2)
        or (graph.nodes[i].id == self.session.active and 2)
        or 0
      if
        priority > 0
        or self.labels == "all"
        or (self.labels ~= "none" and self.zoom * (1 + math.sqrt(deg) * 0.5) >= fade)
      then
        labels[#labels + 1] = { i = i, col = col, row = row, priority = priority, deg = deg }
      end
    end
  end

  table.sort(labels, function(a, b)
    if a.priority ~= b.priority then
      return a.priority > b.priority
    end
    return a.deg > b.deg
  end)
  local label_cells = {}
  for _, lab in ipairs(labels) do
    local node = graph.nodes[lab.i]
    local chars = label_chars(node.name)
    local width = 0
    for _, ch in ipairs(chars) do
      width = width + ch[2]
    end
    -- right of the node, or left of it when it doesn't fit
    local start = lab.col + 2
    if start + width > w then
      start = lab.col - 1 - width
    end
    local free = start >= 0 and start + width <= w
    for c = start - 1, start + width do
      if free and (label_cells[lab.row * w + c] or (c ~= lab.col and occupied[lab.row * w + c])) then
        free = false
      end
    end
    if free or lab.priority >= 3 then
      start = math.max(0, math.min(start, w - width))
      local hl = (focus and not related[lab.i]) and "GraphDim" or (lab.priority >= 2 and "GraphActive" or "GraphLabel")
      if lab.i == focus then
        hl = "GraphSelected"
      end
      -- a blank cell between node and label keeps links from touching the text
      for _, gap in ipairs({ start - 1, start + width }) do
        if gap >= 0 and gap < w and not occupied[lab.row * w + gap] and not label_cells[lab.row * w + gap] then
          cells[lab.row][gap] = { " " }
        end
      end
      local c = start
      for _, ch in ipairs(chars) do
        if c + ch[2] > w then
          break
        end
        cells[lab.row][c] = { ch[1], hl }
        label_cells[lab.row * w + c] = true
        for extra = 1, ch[2] - 1 do
          cells[lab.row][c + extra] = { "" }
          label_cells[lab.row * w + c + extra] = true
        end
        c = c + ch[2]
      end
    end
  end

  local lines, marks = {}, {}
  local cursor
  for r = 0, h - 1 do
    local parts, byte, run_hl, run_start = {}, 0, nil, 0
    for c = 0, w - 1 do
      local cell = cells[r][c]
      if cell[2] ~= run_hl then
        if run_hl then
          marks[#marks + 1] = { r, run_start, byte, run_hl }
        end
        run_hl, run_start = cell[2], byte
      end
      if focus and cell[2] == "GraphSelected" and not cursor then
        cursor = { r + 1, byte }
      end
      parts[#parts + 1] = cell[1]
      byte = byte + #cell[1]
    end
    if run_hl then
      marks[#marks + 1] = { r, run_start, byte, run_hl }
    end
    lines[r + 1] = table.concat(parts)
  end

  vim.bo[self.buf].modifiable = true
  api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)
  vim.bo[self.buf].modifiable = false
  api.nvim_buf_clear_namespace(self.buf, ns, 0, -1)
  for _, m in ipairs(marks) do
    api.nvim_buf_set_extmark(self.buf, ns, m[1], m[2], { end_col = m[3], hl_group = m[4] })
  end
  if cursor and api.nvim_get_current_win() == self.win then
    pcall(api.nvim_win_set_cursor, self.win, cursor)
  end
  self:update_title()
end

function View:update_title()
  local s = self.session.settings
  local mode
  if self.local_graph then
    local c = self:center_index()
    mode = string.format(
      "local: %s · depth %d%s%s%s",
      c and self:graph().nodes[c].name or "?",
      s.localJumps,
      s.localBacklinks and " ←in" or "",
      s.localForelinks and " out→" or "",
      s.localInterlinks and " ↔" or ""
    )
  else
    mode = "global"
  end
  local flags = {}
  if s.search ~= "" then
    flags[#flags + 1] = "/" .. s.search
  end
  if s.showTags then
    flags[#flags + 1] = "tags"
  end
  if s.showAttachments then
    flags[#flags + 1] = "attachments"
  end
  if s.hideUnresolved then
    flags[#flags + 1] = "existing only"
  end
  if not s.showOrphans then
    flags[#flags + 1] = "no orphans"
  end
  local title = string.format(
    " 󰴠 %s · %s · %d nodes %s",
    vim.fs.basename(self.session.root),
    mode,
    #self.view.nodes,
    #flags > 0 and ("· " .. table.concat(flags, " · ") .. " ") or ""
  )
  if self.reveal then
    title = title
      .. string.format("· ▶ %d/%d ", math.min(self.reveal, self.reveal_total or 0), self.reveal_total or 0)
  end
  local footer = " ? help "
  if self.selected then
    local node = self:graph().nodes[self.selected]
    footer = string.format(
      " %s · %s · %d links │ ? help ",
      node.name,
      node.path or node.type,
      self.degree[self.selected] or 0
    )
  end
  if self.last_title ~= title or self.last_footer ~= footer then
    self.last_title, self.last_footer = title, footer
    api.nvim_win_set_config(self.win, { title = title, title_pos = "center", footer = footer, footer_pos = "center" })
  end
end

--- Visible on-screen nodes with their cells: { i, col, row }.
function View:on_screen()
  local w, h = self:size()
  local out = {}
  for k, i in ipairs(self.view.nodes) do
    local n = self.sim.nodes[k]
    local col, row = self:to_cell(n.x, n.y)
    if col >= 0 and row >= 0 and col < w and row < h then
      out[#out + 1] = { i = i, col = col, row = row }
    end
  end
  return out
end

function View:select(i, opts)
  self.selected = i
  if i and (opts or {}).reveal then
    -- pan so the node is on screen
    local p = self.positions[self:graph().nodes[i].id]
    local w, h = self:size()
    local col, row = self:to_cell(p.x, p.y)
    if col < 2 or row < 1 or col >= w - 10 or row >= h - 1 then
      self.follow = false
      self.cx, self.cy = p.x, p.y
    end
  end
  self:render()
end

function View:select_direction(dir)
  local nodes = self:on_screen()
  if #nodes == 0 then
    return
  end
  local from
  if self.selected and self.slot[self.selected] then
    local p = self.sim.nodes[self.slot[self.selected]]
    local col, row = self:to_cell(p.x, p.y)
    from = { col = col, row = row }
  else
    local w, h = self:size()
    from = { col = w / 2, row = h / 2 }
    dir = nil
  end
  local best, best_score
  for _, n in ipairs(nodes) do
    if n.i ~= self.selected then
      local dx, dy = n.col - from.col, (n.row - from.row) * 2 -- cells are ~2x taller than wide
      local along, across
      if dir == "h" then
        along, across = -dx, dy
      elseif dir == "l" then
        along, across = dx, dy
      elseif dir == "k" then
        along, across = -dy, dx
      elseif dir == "j" then
        along, across = dy, dx
      else
        along, across = math.abs(dx) + math.abs(dy), 0
      end
      if along > 0 or not dir then
        local score = along + math.abs(across) * 2
        if not best_score or score < best_score then
          best, best_score = n.i, score
        end
      end
    end
  end
  if best then
    self:select(best)
  end
end

function View:walk(step)
  if not self.selected then
    return self:select_direction(nil)
  end
  local neighbors = self.neighbors[self.selected] or {}
  if #neighbors == 0 then
    return
  end
  local from = self.selected
  -- remember the walk origin so <Tab> cycles through one node's links
  if self.walk_origin ~= from and not vim.tbl_contains(self.neighbors[self.walk_origin or -1] or {}, from) then
    self.walk_origin, self.walk_pos = from, 0
  end
  local origin_neighbors = self.neighbors[self.walk_origin] or neighbors
  self.walk_pos = ((self.walk_pos or 0) + step - 1) % #origin_neighbors + 1
  self:select(origin_neighbors[self.walk_pos], { reveal = true })
end

function View:pan(dx, dy)
  local w, h = self:size()
  self.follow = false
  self.cx = self.cx + dx * w * 0.2 / self.zoom
  self.cy = self.cy + dy * h * 0.8 / self.zoom
  self:render()
end

function View:zoom_by(factor)
  self.follow = false
  self.zoom = math.max(0.005, math.min(self.zoom * factor, 20))
  self:render()
end

function View:open_selected(mode)
  if not self.selected then
    return
  end
  local node = self:graph().nodes[self.selected]
  local session = self.session
  self:close()
  require("custom.graph").open_node(session, node, mode)
end

--- Changes settings; the session's "settings" event then rebuilds the view
--- (and syncs any open browser page), reheating the layout by `alpha`.
function View:set(changes, alpha)
  self.pending_alpha = alpha or 0.5
  self.session:update_settings(changes)
end

function View:toggle(key)
  self:set({ [key] = not self.session.settings[key] })
end

function View:find()
  local items = {}
  for _, i in ipairs(self.view.nodes) do
    items[#items + 1] = i
  end
  vim.ui.select(items, {
    prompt = "Graph node",
    format_item = function(i)
      local node = self:graph().nodes[i]
      return node.path or node.name
    end,
  }, function(i)
    if i then
      self:focus_window()
      self:select(i, { reveal = true })
    end
  end)
end

function View:focus_window()
  if api.nvim_win_is_valid(self.win) then
    api.nvim_set_current_win(self.win)
  end
end

local function rgb_from_hex(hex)
  hex = (hex or ""):gsub("^#", "")
  return #hex == 6 and tonumber(hex, 16) or nil
end

function View:color_groups()
  local groups = vim.deepcopy(self.session.settings.colorGroups)
  local items = { { action = "add" } }
  for k, g in ipairs(groups) do
    items[#items + 1] = { action = "edit", index = k, group = g }
  end
  vim.ui.select(items, {
    prompt = "Color groups (first match wins)",
    format_item = function(item)
      if item.action == "add" then
        return "+ New group"
      end
      return string.format("%d. #%06x  %s", item.index, item.group.color.rgb, item.group.query)
    end,
  }, function(item)
    if not item then
      return self:focus_window()
    end
    local function done()
      self:focus_window()
      self:set({ colorGroups = groups }, 0.05)
    end
    if item.action == "add" then
      vim.ui.input({ prompt = "Query: " }, function(q)
        if not q or q == "" then
          return self:focus_window()
        end
        vim.ui.input({ prompt = "Color (#rrggbb): ", default = "#e0af68" }, function(hex)
          local rgb = rgb_from_hex(hex)
          if rgb then
            table.insert(groups, { query = q, color = { a = 1, rgb = rgb } })
          end
          done()
        end)
      end)
      return
    end
    vim.ui.select({ "Edit query", "Edit color", "Move up", "Delete" }, { prompt = item.group.query }, function(choice)
      local g = groups[item.index]
      if choice == "Edit query" then
        vim.ui.input({ prompt = "Query: ", default = g.query }, function(q)
          if q then
            g.query = q
          end
          done()
        end)
      elseif choice == "Edit color" then
        vim.ui.input({ prompt = "Color (#rrggbb): ", default = string.format("#%06x", g.color.rgb) }, function(hex)
          local rgb = rgb_from_hex(hex)
          if rgb then
            g.color.rgb = rgb
          end
          done()
        end)
      elseif choice == "Move up" and item.index > 1 then
        groups[item.index], groups[item.index - 1] = groups[item.index - 1], groups[item.index]
        done()
      elseif choice == "Delete" then
        table.remove(groups, item.index)
        done()
      else
        self:focus_window()
      end
    end)
  end)
end

local SETTINGS = {
  { "Filters" },
  { "search", "Search filter", "string" },
  { "showTags", "Tags", "bool" },
  { "showAttachments", "Attachments", "bool" },
  { "hideUnresolved", "Existing files only", "bool" },
  { "showOrphans", "Orphans", "bool" },
  { "Display" },
  { "textFadeMultiplier", "Text fade threshold (-3 … 3)", "number" },
  { "nodeSizeMultiplier", "Node size (0.1 … 5)", "number" },
  { "lineSizeMultiplier", "Link thickness (browser only)", "number" },
  { "showArrow", "Arrows (browser only)", "bool" },
  { "Forces" },
  { "centerStrength", "Center force (0 … 1)", "number" },
  { "repelStrength", "Repel force (0 … 20)", "number" },
  { "linkStrength", "Link force (0 … 1)", "number" },
  { "linkDistance", "Link distance (30 … 500)", "number" },
  { "Local graph" },
  { "localJumps", "Depth (1 … 5)", "number" },
  { "localBacklinks", "Incoming links", "bool" },
  { "localForelinks", "Outgoing links", "bool" },
  { "localInterlinks", "Neighbor links", "bool" },
}

function View:settings_menu()
  local s = self.session.settings
  local items = vim.tbl_filter(function(item)
    return item[2] ~= nil
  end, SETTINGS)
  vim.ui.select(items, {
    prompt = "Graph settings",
    format_item = function(item)
      local value = s[item[1]]
      if item[3] == "bool" then
        return string.format("[%s] %s", value and "x" or " ", item[2])
      elseif item[3] == "number" then
        return string.format("%s: %.2f", item[2], value)
      end
      return string.format("%s: %s", item[2], value)
    end,
  }, function(item)
    if not item then
      return self:focus_window()
    end
    if item[3] == "bool" then
      self:focus_window()
      self:toggle(item[1])
      return self:settings_menu()
    end
    vim.ui.input({ prompt = item[2] .. ": ", default = tostring(s[item[1]]) }, function(value)
      self:focus_window()
      if value then
        local v = item[3] == "number" and tonumber(value) or value
        if v ~= nil then
          self:set({ [item[1]] = v }, 0.8)
        end
      end
      self:settings_menu()
    end)
  end)
end

function View:animate()
  if self.reveal then
    self.reveal = nil
    return self:rebuild(0.3)
  end
  self.reveal = 0
  self.positions = {}
  self.follow = true
  self:rebuild(1)
  local total = self.reveal_total or 0
  local step = math.max(1, math.ceil(total / 90))
  local timer = uv.new_timer()
  self.reveal_timer = timer
  timer:start(
    60,
    60,
    vim.schedule_wrap(function()
      if not self.reveal or not api.nvim_win_is_valid(self.win) then
        timer:stop()
        timer:close()
        if self.reveal_timer == timer then
          self.reveal_timer = nil
        end
        return
      end
      self.reveal = self.reveal + step
      if self.reveal >= total then
        self.reveal = nil
      end
      self:rebuild(math.max(self.sim.alpha, 0.4))
    end)
  )
end

function View:help()
  local lines = {}
  for _, row in ipairs(HELP) do
    lines[#lines + 1] = string.format("  %-18s %s", row[1], row[2])
  end
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  local width = 0
  for _, l in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(l) + 2)
  end
  local win = api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = #lines,
    row = math.floor((vim.o.lines - #lines) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    border = "rounded",
    title = " Graph keys ",
    title_pos = "center",
    zindex = 60,
  })
  for _, key in ipairs({ "q", "<Esc>", "?" }) do
    vim.keymap.set("n", key, function()
      api.nvim_win_close(win, true)
    end, { buffer = buf, nowait = true })
  end
end

function View:mouse_select(open)
  local pos = vim.fn.getmousepos()
  if pos.winid ~= self.win then
    return
  end
  local origin = vim.fn.win_screenpos(self.win)
  local col, row = pos.screencol - origin[2] - 1, pos.screenrow - origin[1] - 1
  local best, best_d
  for _, n in ipairs(self:on_screen()) do
    local d = math.abs(n.col - col) + math.abs(n.row - row) * 2
    if d <= 4 and (not best_d or d < best_d) then
      best, best_d = n.i, d
    end
  end
  if best then
    if open and best == self.selected then
      return self:open_selected("edit")
    end
    self:select(best)
  end
end

function View:keymaps()
  local function map(lhs, fn, desc)
    vim.keymap.set("n", lhs, fn, { buffer = self.buf, nowait = true, silent = true, desc = desc })
  end
  for _, dir in ipairs({ "h", "j", "k", "l" }) do
    map(dir, function()
      self:select_direction(dir)
    end)
  end
  local pans = {
    H = { -1, 0 },
    L = { 1, 0 },
    K = { 0, -1 },
    J = { 0, 1 },
    ["<Left>"] = { -1, 0 },
    ["<Right>"] = { 1, 0 },
    ["<Up>"] = { 0, -1 },
    ["<Down>"] = { 0, 1 },
  }
  for lhs, d in pairs(pans) do
    map(lhs, function()
      self:pan(d[1], d[2])
    end)
  end
  map("<Tab>", function()
    self:walk(1)
  end)
  map("<S-Tab>", function()
    self:walk(-1)
  end)
  map("+", function()
    self:zoom_by(1.25)
  end)
  map("=", function()
    self:zoom_by(1.25)
  end)
  map("-", function()
    self:zoom_by(0.8)
  end)
  map("<ScrollWheelUp>", function()
    self:zoom_by(1.15)
  end)
  map("<ScrollWheelDown>", function()
    self:zoom_by(1 / 1.15)
  end)
  map("0", function()
    self.follow = true
    self:fit()
    self:render()
  end)
  map("<LeftMouse>", function()
    self:mouse_select(false)
  end)
  map("<2-LeftMouse>", function()
    self:mouse_select(true)
  end)
  map("<CR>", function()
    self:open_selected("edit")
  end)
  map("<C-v>", function()
    self:open_selected("vsplit")
  end)
  map("<C-s>", function()
    self:open_selected("split")
  end)
  map("<C-t>", function()
    self:open_selected("tab")
  end)
  map("c", function()
    if self.selected then
      self.center = self:graph().nodes[self.selected].id
      self.local_graph = true
      self.follow = true
      self:rebuild(0.8)
    end
  end)
  map("g", function()
    self.local_graph = not self.local_graph
    if self.local_graph and not self:center_index() then
      if self.selected then
        self.center = self:graph().nodes[self.selected].id
      else
        vim.notify("Graph: select a node (or open a note) for the local graph", vim.log.levels.WARN)
        self.local_graph = false
        return
      end
    end
    self.follow = true
    self:rebuild(0.8)
  end)
  map("[", function()
    self:set({ localJumps = math.max(1, self.session.settings.localJumps - 1) })
  end)
  map("]", function()
    self:set({ localJumps = math.min(5, self.session.settings.localJumps + 1) })
  end)
  map("i", function()
    self:toggle("localBacklinks")
  end)
  map("e", function()
    self:toggle("localForelinks")
  end)
  map("n", function()
    self:toggle("localInterlinks")
  end)
  map("t", function()
    self:toggle("showTags")
  end)
  map("a", function()
    self:toggle("showAttachments")
  end)
  map("u", function()
    self:toggle("hideUnresolved")
  end)
  map("o", function()
    self:toggle("showOrphans")
  end)
  map("/", function()
    vim.ui.input({ prompt = "Search filter: ", default = self.session.settings.search }, function(q)
      self:focus_window()
      if q then
        self.follow = true
        self:set({ search = q }, 0.8)
      end
    end)
  end)
  map("f", function()
    self:find()
  end)
  map("G", function()
    self:color_groups()
  end)
  map("s", function()
    self:settings_menu()
  end)
  map("A", function()
    self:animate()
  end)
  map("r", function()
    self.sim:reheat(1)
    self:start()
  end)
  map("R", function()
    self.follow = true
    self.pending_alpha = 1
    self.session:reset_settings()
  end)
  map("b", function()
    local local_graph = self.local_graph
    self:close()
    require("custom.graph").browser({ local_graph = local_graph })
  end)
  map("T", function()
    self.labels = ({ auto = "all", all = "none", none = "auto" })[self.labels]
    vim.notify("Graph labels: " .. self.labels, vim.log.levels.INFO)
    self:render()
  end)
  map("?", function()
    self:help()
  end)
  map("q", function()
    self:close()
  end)
  map("<Esc>", function()
    if self.selected then
      self:select(nil)
    else
      self:close()
    end
  end)
end

function View:layout()
  local width = math.max(20, vim.o.columns - 6)
  local height = math.max(6, vim.o.lines - vim.o.cmdheight - 6)
  return {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - vim.o.cmdheight - height) / 2) - 1,
    col = math.floor((vim.o.columns - width) / 2),
  }
end

function View:close()
  if self.closed then
    return
  end
  self.closed = true
  if self.unsubscribe then
    self.unsubscribe()
  end
  if not self.timer:is_closing() then
    self.timer:stop()
    self.timer:close()
  end
  self.reveal = nil
  pcall(api.nvim_del_augroup_by_id, self.augroup)
  if api.nvim_win_is_valid(self.win) then
    api.nvim_win_close(self.win, true)
  end
  M.current = nil
end

---@param session graph.Session
function M.open(session, opts)
  opts = opts or {}
  if M.current then
    M.current:close()
  end
  set_highlights()

  local self = setmetatable({
    session = session,
    local_graph = opts.local_graph or false,
    center = nil, -- nil: follow the active note
    positions = {},
    follow = true,
    labels = "auto",
    zoom = 1,
    cx = 0,
    cy = 0,
    timer = uv.new_timer(),
  }, View)

  self.buf = api.nvim_create_buf(false, true)
  vim.bo[self.buf].bufhidden = "wipe"
  vim.bo[self.buf].filetype = "graphview"
  local config = self:layout()
  config.border = "rounded"
  config.style = "minimal"
  config.title = " Graph "
  config.title_pos = "center"
  self.win = api.nvim_open_win(self.buf, true, config)
  vim.wo[self.win].wrap = false
  vim.wo[self.win].cursorline = false
  vim.wo[self.win].winhighlight = "NormalFloat:Normal"

  self.augroup = api.nvim_create_augroup("custom.graph.term." .. self.buf, { clear = true })
  api.nvim_create_autocmd("VimResized", {
    group = self.augroup,
    callback = function()
      if api.nvim_win_is_valid(self.win) then
        api.nvim_win_set_config(self.win, self:layout())
        self:render()
      end
    end,
  })
  api.nvim_create_autocmd({ "BufWipeout", "WinClosed" }, {
    group = self.augroup,
    buffer = self.buf,
    callback = function()
      vim.schedule(function()
        self:close()
      end)
    end,
  })

  self.unsubscribe = session:subscribe(function(event)
    vim.schedule(function()
      if self.closed then
        return
      end
      if event == "graph" or event == "settings" then
        self:rebuild(self.pending_alpha or 0.3)
        self.pending_alpha = nil
      elseif event == "active" and self.local_graph and not self.center then
        self.follow = true
        self:rebuild(0.8)
      else
        self:render()
      end
    end)
  end)

  self:keymaps()
  self:rebuild(1)
  -- start with the current note selected, like Obsidian highlights it
  local active = session.active and session.graph.index[session.active]
  if active and self.slot[active] then
    self.selected = active
  end
  M.current = self
  return self
end

return M
