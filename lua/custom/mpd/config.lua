local M = {}

---@class mpd.Config
---@field host string a path starting with "/" is treated as a unix socket
---@field port integer
M.options = {
  host = vim.env.MPD_HOST or "127.0.0.1",
  port = tonumber(vim.env.MPD_PORT) or 6600,
}

---@param opts? mpd.Config|{}
function M.setup(opts)
  M.options = vim.tbl_extend("force", M.options, opts or {})
end

return M
