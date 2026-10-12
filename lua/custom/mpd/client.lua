-- The MPD protocol, spoken directly over TCP (or a unix socket) via vim.uv.
local config = require("custom.mpd.config")
local util = require("custom.mpd.util")

local M = {}

local function quote(arg)
  return '"' .. tostring(arg):gsub("\\", "\\\\"):gsub('"', '\\"') .. '"'
end

--- Builds a protocol line from a command and its arguments.
local function build(cmd)
  if type(cmd) == "string" then
    return cmd
  end
  local parts = { cmd[1] }
  for i = 2, #cmd do
    table.insert(parts, quote(cmd[i]))
  end
  return table.concat(parts, " ")
end

--- Sends one or more commands on a fresh connection.
--- On success `cb(pairs, binary)` is called on the main loop, where `pairs` is a
--- list of { key, value } and `binary` is the payload of a `binary:` response, if any.
---@param cmds string|table|table[] a command, or a list of commands (sent as a command list)
---@param cb? fun(pairs: table, binary?: string)
---@param on_error? fun(err: string) defaults to an error notification
function M.request(cmds, cb, on_error)
  if type(cmds) == "string" or type(cmds[1]) == "string" then
    cmds = { cmds }
  end
  local lines = vim.tbl_map(build, cmds)
  local payload = #lines == 1 and lines[1]
    or ("command_list_begin\n" .. table.concat(lines, "\n") .. "\ncommand_list_end")

  local host, port = config.options.host, config.options.port
  local is_unix = host:sub(1, 1) == "/"
  local handle = is_unix and vim.uv.new_pipe(false) or vim.uv.new_tcp()
  local buf, pos, greeted, done = "", 1, false, false
  local result, binary = {}, nil

  local function finish(err)
    if done then
      return
    end
    done = true
    if not handle:is_closing() then
      handle:close()
    end
    vim.schedule(function()
      if err then
        (on_error or function(e)
          util.notify(e, vim.log.levels.ERROR)
        end)(err)
      elseif cb then
        cb(result, binary)
      end
    end)
  end

  -- Consumes complete lines from `buf`; binary payloads are read by length.
  local function consume()
    while not done do
      local nl = buf:find("\n", pos, true)
      if not nl then
        return
      end
      local line = buf:sub(pos, nl - 1)
      if not greeted then
        if not line:match("^OK MPD ") then
          return finish("unexpected greeting: " .. line)
        end
        greeted = true
        pos = nl + 1
      elseif line == "OK" then
        return finish()
      elseif line:sub(1, 4) == "ACK " then
        return finish(line:sub(5))
      else
        local key, value = line:match("^([^:]+): (.*)$")
        if key == "binary" then
          local len = tonumber(value)
          -- payload is followed by a newline
          if #buf < nl + len + 1 then
            return
          end
          binary = buf:sub(nl + 1, nl + len)
          pos = nl + len + 2
        else
          if key then
            table.insert(result, { key, value })
          end
          pos = nl + 1
        end
      end
    end
  end

  local function on_connect(err)
    if err then
      return finish(("cannot connect to %s%s: %s"):format(host, is_unix and "" or (":" .. port), err))
    end
    handle:read_start(function(read_err, chunk)
      if read_err then
        return finish(read_err)
      end
      if not chunk then
        return finish("connection closed unexpectedly")
      end
      buf = buf .. chunk
      consume()
    end)
    handle:write(payload .. "\n")
  end

  if is_unix then
    handle:connect(host, on_connect)
  else
    vim.uv.getaddrinfo(host, nil, { socktype = "stream" }, function(err, res)
      if err or not res or not res[1] then
        return finish(("cannot resolve %s: %s"):format(host, err or "no address"))
      end
      handle:connect(res[1].addr, port, on_connect)
    end)
  end
end

--- Sends `cmds`, then notifies `msg` (when given) and calls `cb`.
---@param msg? string
---@param cb? fun()
function M.send(cmds, msg, cb)
  M.request(cmds, function()
    if msg then
      util.notify(msg)
    end
    if cb then
      cb()
    end
  end)
end

return M
