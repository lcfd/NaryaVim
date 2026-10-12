-- Minimal HTTP server on 127.0.0.1 serving the browser graph view.
-- The page talks back to Neovim (open a note, save settings) and receives
-- live updates (vault changed, active note changed) over Server-Sent Events.
-- Every API call must carry a random per-server token, so other local pages
-- can't drive the editor.
local M = {}

local uv = vim.uv

local STATUS = { [200] = "OK", [204] = "No Content", [400] = "Bad Request", [403] = "Forbidden", [404] = "Not Found" }

local function random_token()
  local bytes = assert(uv.random(16))
  return (bytes:gsub(".", function(c)
    return string.format("%02x", c:byte())
  end))
end

local function parse_query(qs)
  local params = {}
  for pair in (qs or ""):gmatch("[^&]+") do
    local k, v = pair:match("^([^=]*)=?(.*)$")
    params[k] = v:gsub("+", " "):gsub("%%(%x%x)", function(h)
      return string.char(tonumber(h, 16))
    end)
  end
  return params
end

local function respond(client, status, content_type, body)
  body = body or ""
  local head = table.concat({
    string.format("HTTP/1.1 %d %s", status, STATUS[status] or ""),
    "Content-Type: " .. content_type,
    "Content-Length: " .. #body,
    "Cache-Control: no-store",
    "Connection: close",
    "",
    "",
  }, "\r\n")
  client:write(head .. body, function()
    if not client:is_closing() then
      client:close()
    end
  end)
end

---@class graph.Server
---@field port integer
---@field token string
---@field url string
---@field close fun()
---@field broadcast fun(event: string, data: any)

--- Starts a server. `routes[path](request) -> status, content_type, body`;
--- `on_events(send)` is called for each new event-stream client.
---@return graph.Server|nil
function M.start(routes)
  local tcp = uv.new_tcp()
  if not tcp then
    return nil
  end
  tcp:bind("127.0.0.1", 0)
  local token = random_token()
  local streams = {}
  local self = { token = token }

  local function handle(client, request)
    local method, target = request.head:match("^(%u+) (%S+)")
    if not method then
      return respond(client, 400, "text/plain", "bad request")
    end
    local path, qs = target:match("^([^?]*)%??(.*)$")
    local params = parse_query(qs)
    -- reject other hosts (DNS rebinding) and requests without the token
    local host = request.head:match("\r\n[Hh]ost:%s*([^\r\n]+)")
    if host ~= "127.0.0.1:" .. self.port and host ~= "localhost:" .. self.port then
      return respond(client, 403, "text/plain", "forbidden")
    end
    if params.t ~= token then
      return respond(client, 403, "text/plain", "missing or wrong token: reopen the graph from Neovim")
    end

    if path == "/events" then
      client:write(
        "HTTP/1.1 200 OK\r\nContent-Type: text/event-stream\r\nCache-Control: no-store\r\nConnection: keep-alive\r\n\r\n"
          .. ": connected\n\n"
      )
      streams[client] = true
      return
    end

    local route = routes[method .. " " .. path]
    if not route then
      return respond(client, 404, "text/plain", "not found")
    end
    vim.schedule(function()
      local ok, status, content_type, body = pcall(route, { params = params, body = request.body })
      if not ok then
        vim.notify("Graph server: " .. tostring(status), vim.log.levels.ERROR)
        status, content_type, body = 400, "text/plain", tostring(status)
      end
      if not client:is_closing() then
        respond(client, status, content_type, body)
      end
    end)
  end

  local ok, err = pcall(function()
    tcp:listen(64, function(listen_err)
      if listen_err then
        return
      end
      local client = uv.new_tcp()
      tcp:accept(client)
      local buffer, handled = "", false
      client:read_start(function(read_err, chunk)
        if read_err or not chunk then
          streams[client] = nil
          if not client:is_closing() then
            client:close()
          end
          return
        end
        if handled then
          return
        end
        buffer = buffer .. chunk
        local head_end = buffer:find("\r\n\r\n", 1, true)
        if not head_end then
          return
        end
        local head = buffer:sub(1, head_end - 1)
        local length = tonumber(head:match("\r\n[Cc]ontent%-[Ll]ength:%s*(%d+)")) or 0
        local body = buffer:sub(head_end + 4)
        if #body < length then
          return
        end
        handled = true
        -- event streams keep reading so a closed tab is noticed (EOF above)
        if not head:match("^GET /events") then
          client:read_stop()
        end
        handle(client, { head = head, body = body:sub(1, length) })
      end)
    end)
  end)
  if not ok then
    vim.notify("Graph server failed to start: " .. tostring(err), vim.log.levels.ERROR)
    tcp:close()
    return nil
  end

  self.port = tcp:getsockname().port
  self.url = string.format("http://127.0.0.1:%d/?t=%s", self.port, token)

  function self.broadcast(event, data)
    local payload = string.format("event: %s\ndata: %s\n\n", event, vim.json.encode(data))
    for client in pairs(streams) do
      if client:is_closing() then
        streams[client] = nil
      else
        client:write(payload)
      end
    end
  end

  -- keep event streams alive through proxies and detect closed tabs
  local heartbeat = uv.new_timer()
  heartbeat:start(15000, 15000, function()
    for client in pairs(streams) do
      if client:is_closing() then
        streams[client] = nil
      else
        client:write(": ping\n\n")
      end
    end
  end)

  function self.close()
    heartbeat:stop()
    heartbeat:close()
    for client in pairs(streams) do
      if not client:is_closing() then
        client:close()
      end
    end
    streams = {}
    if not tcp:is_closing() then
      tcp:close()
    end
  end

  function self.clients()
    return vim.tbl_count(streams)
  end

  return self
end

return M
