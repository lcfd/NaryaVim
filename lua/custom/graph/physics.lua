-- Force-directed layout (a port of d3-force's link, many-body and x/y forces
-- with a Barnes-Hut quadtree). Mirrors the simulation in web/index.html so
-- the terminal and browser views settle into similar shapes.
local M = {}

local sqrt, random = math.sqrt, math.random

local THETA2 = 0.81
local DIST_MIN2 = 1

---@class graph.SimNode
---@field x number
---@field y number
---@field vx number
---@field vy number
---@field fx number|nil  pinned position (while dragging)
---@field fy number|nil

local Sim = {}
Sim.__index = Sim

--- Maps Obsidian's force settings onto simulation parameters.
function M.forces(settings)
  return {
    charge = -settings.repelStrength * 40,
    center = settings.centerStrength * 0.1,
    link_strength = settings.linkStrength,
    link_distance = settings.linkDistance,
  }
end

---@param nodes graph.SimNode[]
---@param links integer[][] pairs of indices into `nodes`
function M.new(nodes, links, forces)
  local self = setmetatable({
    nodes = nodes,
    links = links,
    alpha = 1,
    alpha_min = 0.001,
    alpha_decay = 1 - 0.001 ^ (1 / 300),
    alpha_target = 0,
    velocity_decay = 0.6,
  }, Sim)
  self:set_forces(forces)
  for i, n in ipairs(nodes) do
    -- phyllotaxis arrangement for nodes without a position yet
    if not n.x then
      local r, angle = 10 * sqrt(0.5 + i), i * math.pi * (3 - sqrt(5))
      n.x, n.y = r * math.cos(angle), r * math.sin(angle)
    end
    n.vx, n.vy = n.vx or 0, n.vy or 0
  end
  return self
end

function Sim:set_forces(forces)
  self.forces = forces
  local count = {}
  for _, l in ipairs(self.links) do
    count[l[1]] = (count[l[1]] or 0) + 1
    count[l[2]] = (count[l[2]] or 0) + 1
  end
  self.link_bias, self.link_strength = {}, {}
  for k, l in ipairs(self.links) do
    local a, b = count[l[1]], count[l[2]]
    self.link_bias[k] = a / (a + b)
    self.link_strength[k] = forces.link_strength / math.min(a, b)
  end
end

function Sim:reheat(alpha)
  self.alpha = math.max(self.alpha, alpha or 0.3)
end

local function jiggle()
  return (random() - 0.5) * 1e-6
end

local function build_tree(nodes, charge)
  local x0, y0, x1, y1 = math.huge, math.huge, -math.huge, -math.huge
  for _, n in ipairs(nodes) do
    x0, y0 = math.min(x0, n.x), math.min(y0, n.y)
    x1, y1 = math.max(x1, n.x), math.max(y1, n.y)
  end
  local size = math.max(x1 - x0, y1 - y0, 1)
  local root = { x0 = x0, y0 = y0, size = size }

  local function insert(q, n, depth)
    if q.children then
      local half = q.size / 2
      local ix = n.x >= q.x0 + half and 1 or 0
      local iy = n.y >= q.y0 + half and 2 or 0
      local slot = ix + iy + 1
      local child = q.children[slot]
      if not child then
        child = { x0 = q.x0 + ix * half, y0 = q.y0 + (iy / 2) * half, size = half }
        q.children[slot] = child
      end
      insert(child, n, depth + 1)
    elseif q.points and depth < 24 then
      -- split the leaf, then insert the old and new points
      local points = q.points
      q.points, q.children = nil, {}
      for _, p in ipairs(points) do
        insert(q, p, depth)
      end
      insert(q, n, depth)
    else
      q.points = q.points or {}
      q.points[#q.points + 1] = n
    end
  end
  for _, n in ipairs(nodes) do
    insert(root, n, 0)
  end

  -- aggregate strength and center of mass bottom-up
  local function accumulate(q)
    local strength, cx, cy = 0, 0, 0
    if q.children then
      for _, c in pairs(q.children) do
        accumulate(c)
        strength = strength + c.value
        cx, cy = cx + c.value * c.cx, cy + c.value * c.cy
      end
    else
      for _, p in ipairs(q.points) do
        strength = strength + charge
        cx, cy = cx + charge * p.x, cy + charge * p.y
      end
    end
    q.value = strength
    q.cx, q.cy = cx / strength, cy / strength
  end
  accumulate(root)
  return root
end

local function apply_charge(q, n, alpha, charge)
  local dx, dy = q.cx - n.x, q.cy - n.y
  local l = dx * dx + dy * dy
  if q.children then
    if q.size * q.size / THETA2 < l then
      if l < DIST_MIN2 then
        l = sqrt(DIST_MIN2 * l)
      end
      n.vx = n.vx + dx * q.value * alpha / l
      n.vy = n.vy + dy * q.value * alpha / l
      return
    end
    for _, c in pairs(q.children) do
      apply_charge(c, n, alpha, charge)
    end
    return
  end
  for _, p in ipairs(q.points) do
    if p ~= n then
      dx, dy = p.x - n.x, p.y - n.y
      if dx == 0 then
        dx = jiggle()
      end
      if dy == 0 then
        dy = jiggle()
      end
      l = dx * dx + dy * dy
      if l < DIST_MIN2 then
        l = sqrt(DIST_MIN2 * l)
      end
      n.vx = n.vx + dx * charge * alpha / l
      n.vy = n.vy + dy * charge * alpha / l
    end
  end
end

--- Advances the simulation by one tick. Returns false once it has cooled down.
function Sim:tick()
  if self.alpha < self.alpha_min then
    return false
  end
  self.alpha = self.alpha + (self.alpha_target - self.alpha) * self.alpha_decay
  local alpha, nodes, f = self.alpha, self.nodes, self.forces

  for k, l in ipairs(self.links) do
    local s, t = nodes[l[1]], nodes[l[2]]
    local x = t.x + t.vx - s.x - s.vx
    local y = t.y + t.vy - s.y - s.vy
    if x == 0 then
      x = jiggle()
    end
    if y == 0 then
      y = jiggle()
    end
    local len = sqrt(x * x + y * y)
    len = (len - f.link_distance) / len * alpha * self.link_strength[k]
    x, y = x * len, y * len
    local bias = self.link_bias[k]
    t.vx, t.vy = t.vx - x * bias, t.vy - y * bias
    s.vx, s.vy = s.vx + x * (1 - bias), s.vy + y * (1 - bias)
  end

  if #nodes > 1 then
    local tree = build_tree(nodes, f.charge)
    for _, n in ipairs(nodes) do
      apply_charge(tree, n, alpha, f.charge)
    end
  end

  local keep = 1 - self.velocity_decay
  for _, n in ipairs(nodes) do
    n.vx = n.vx - n.x * f.center * alpha
    n.vy = n.vy - n.y * f.center * alpha
    if n.fx then
      n.x, n.vx = n.fx, 0
    else
      n.vx = n.vx * keep
      n.x = n.x + n.vx
    end
    if n.fy then
      n.y, n.vy = n.fy, 0
    else
      n.vy = n.vy * keep
      n.y = n.y + n.vy
    end
  end
  return true
end

return M
