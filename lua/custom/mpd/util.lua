local M = {}

function M.notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "MPD" })
end

--- `m:ss`, or `h:mm:ss` from an hour on.
function M.fmt_time(seconds)
  seconds = math.floor(tonumber(seconds) or 0)
  if seconds >= 3600 then
    return ("%d:%02d:%02d"):format(math.floor(seconds / 3600), math.floor(seconds / 60) % 60, seconds % 60)
  end
  return ("%d:%02d"):format(math.floor(seconds / 60), seconds % 60)
end

--- Formats an ISO 8601 UTC timestamp (as MPD sends them) in local time.
function M.fmt_date(iso)
  local y, mo, d, h, mi, s = iso:match("^(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
  if not y then
    return iso
  end
  -- os.time reads the fields as local time: shift by the local UTC offset
  local t = os.time({ year = y, month = mo, day = d, hour = h, min = mi, sec = s })
  local now = os.time()
  local offset = os.difftime(now, os.time(os.date("!*t", now) --[[@as osdateparam]]))
  return os.date("%Y-%m-%d %H:%M", t + offset)
end

return M
