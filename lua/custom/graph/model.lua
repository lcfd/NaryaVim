-- Applies the graph settings (filters, local graph) to a scanned vault and
-- returns the visible subgraph. Mirrors `computeView()` in web/index.html.
local M = {}

local query = require("custom.graph.query")

---@class graph.View
---@field nodes integer[]            visible node indices into graph.nodes
---@field links integer[][]          visible links (graph.nodes indices)
---@field depth table<integer, integer>|nil  local graph: distance from the center
---@field colors table<integer, integer>     node index -> rgb of its color group

---@param graph graph.Graph
---@param settings table
---@param center integer|nil  node index for a local graph
---@return graph.View
function M.view(graph, settings, center)
  local keep = {}
  local matches = query.match(graph, settings.search)
  for i, node in ipairs(graph.nodes) do
    local t = node.type
    if
      (t == "note" or (t == "attachment" and settings.showAttachments) or (t == "tag" and settings.showTags))
      or (t == "unresolved" and not settings.hideUnresolved)
    then
      keep[i] = not node.path or not matches or matches[i] or false
    end
  end
  -- the center of a local graph is always shown
  if center then
    keep[center] = true
  end

  -- tags and unresolved links only show up when a visible file links to them
  local links, linked = {}, {}
  for _, link in ipairs(graph.links) do
    local a, b = link[1], link[2]
    if keep[a] and keep[b] then
      links[#links + 1] = link
      if graph.nodes[a].path then
        linked[b] = true
      end
    end
  end
  for i in pairs(keep) do
    if not graph.nodes[i].path and not linked[i] and i ~= center then
      keep[i] = false
    end
  end

  local depth
  if center then
    depth = { [center] = 0 }
    local out_edges, in_edges = {}, {}
    for _, link in ipairs(links) do
      local a, b = link[1], link[2]
      if keep[a] and keep[b] then
        out_edges[a] = out_edges[a] or {}
        table.insert(out_edges[a], b)
        in_edges[b] = in_edges[b] or {}
        table.insert(in_edges[b], a)
      end
    end
    local frontier = { center }
    for d = 1, settings.localJumps do
      local next_frontier = {}
      local function visit(list)
        for _, j in ipairs(list or {}) do
          if depth[j] == nil then
            depth[j] = d
            next_frontier[#next_frontier + 1] = j
          end
        end
      end
      for _, i in ipairs(frontier) do
        if settings.localForelinks then
          visit(out_edges[i])
        end
        if settings.localBacklinks then
          visit(in_edges[i])
        end
      end
      frontier = next_frontier
    end
    for i in pairs(keep) do
      keep[i] = depth[i] ~= nil
    end
  end

  local degree = {}
  local visible_links = {}
  for _, link in ipairs(links) do
    local a, b = link[1], link[2]
    if keep[a] and keep[b] then
      local ok = true
      if depth and depth[a] == depth[b] then
        -- links between nodes at the same distance are "neighbor links"
        ok = settings.localInterlinks
      end
      if ok then
        visible_links[#visible_links + 1] = link
        degree[a] = (degree[a] or 0) + 1
        degree[b] = (degree[b] or 0) + 1
      end
    end
  end

  local nodes = {}
  for i = 1, #graph.nodes do
    if keep[i] and (settings.showOrphans or depth or degree[i]) then
      nodes[#nodes + 1] = i
    end
  end

  local colors = {}
  for gi = #settings.colorGroups, 1, -1 do -- earlier groups win
    local group = settings.colorGroups[gi]
    local set = query.match(graph, group.query)
    if set then
      for i in pairs(set) do
        colors[i] = group.color.rgb
      end
    end
  end

  return { nodes = nodes, links = visible_links, depth = depth, colors = colors }
end

return M
